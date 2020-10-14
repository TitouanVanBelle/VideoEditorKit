//
//  VideoEditorStore.swift
//  
//
//  Created by Titouan Van Belle on 11.09.20.
//

import AVFoundation
import Combine
import CombineFeedback
import CombineFeedbackUI
import Foundation
import VideoEditor

public final class VideoEditorStore: Store<VideoEditorStore.State, VideoEditorStore.Event> {
    init(
        editor: VideoEditorProtocol,
        generator: VideoTimelineGeneratorProtocol
    ) {
        super.init(initial: State(),
                   feedbacks: [
                    Self.whenGeneratingTimeline(generator: generator),
                    Self.whenUpdatingAsset(editor: editor)
                   ],
                   reducer: Self.reducer())
    }
}

// MARK: Inner Types

public extension VideoEditorStore {
    enum Side {
        case left
        case right
    }

    struct State {
        enum Status: Equatable {
            case idle
            case generatingTimeline
            case seeking
            case trimming(Side)
            case assetEdited(AVAsset, AVVideoComposition)
            case updatingAsset
            case saving
        }

        var bounds: CGRect = .zero
        var timeline: [CGImage] = []

        var originalAsset: AVAsset?
        var editedAsset: AVAsset?
        var videoComposition: AVVideoComposition?

        var shouldSeekBackToBeginning = false
        var shouldUpdateSeekerPosition = false

        var videoProgress: Double = 0.0
        var manualSeekPosition: Double = 0.0

        var speedRate: Double = 1.0

        var leftHandTrimMarkerPosition: Double = 0.0
        var rightHandTrimMarkerPosition: Double = 1.0

        var croppingPreset: CroppingPreset = .portrait

        var status: Status = .idle
    }

    enum Event {
        case load(AVAsset)
        case generateTimeline(CGRect)
        case timelineGenerated([CGImage])
        case failedToGenerateTimeline

        case videoProgress(Double)

        case seek(Double)
        case stopSeeking

        case trim(Side, Double)
        case stopTrimming

        case updateSpeed(Double)
        case updateCroppingPreset(CroppingPreset)
        case assetEdited(VideoEditResult)
        case failedToEditAsset(Error)

        case save

        case reset
    }
}

// MARK: State Machine

fileprivate extension VideoEditorStore {
    static func reducer() -> Reducer<State, Event> {
        .init { state, event in
            switch event {
            case .load(let asset):
                state.originalAsset = asset
                state.editedAsset = asset

            case .generateTimeline(let bounds):
                state.bounds = bounds
                state.status = .generatingTimeline

            case .timelineGenerated(let timeline):
                state.timeline = timeline
                state.status = .idle

            case .failedToGenerateTimeline:
                /// - TODO: Notify user
                return

            case .videoProgress(let progress):
                state.videoProgress = progress

            case .seek(let position):
                state.status = .seeking
                state.manualSeekPosition = position

            case .stopSeeking:
                state.status = .idle

            case .trim(let side, let position):
                switch side {
                case .left:
                    state.leftHandTrimMarkerPosition = position
                case .right:
                    state.rightHandTrimMarkerPosition = position
                }

                state.status = .trimming(side)

            case .stopTrimming:
                state.videoProgress = .zero
                state.shouldSeekBackToBeginning = true
                state.status = .updatingAsset

            case .updateSpeed(let speedRate):
                if state.speedRate != speedRate {
                    state.speedRate = speedRate
                    state.status = .updatingAsset
                }

            case .updateCroppingPreset(let croppingPreset):
                state.croppingPreset = croppingPreset
                state.status = .updatingAsset

            case .assetEdited(let result):
                state.editedAsset = result.asset
                state.videoComposition = result.videoComposition
                state.status = .assetEdited(result.asset, result.videoComposition)

            case .failedToEditAsset( _):
                /// - TODO:
                return

            case .reset:
                state.shouldSeekBackToBeginning = false
                state.status = .idle

            case .save:
                state.status = .saving
            }
        }
    }
}

// MARK: Feedbacks

fileprivate extension VideoEditorStore {
    static func whenGeneratingTimeline(generator: VideoTimelineGeneratorProtocol) -> Feedback<State, Event> {
        .custom { state, consumer in
            state
                .map { $0.0 }
                .filter { .generatingTimeline == $0.status }
                .flatMapLatest { state in
                    generator.generateTimeline(for: state.originalAsset!, within: state.bounds, count: state.numberOfFrames(within: state.bounds))
                        .receive(on: DispatchQueue.main)
                        .map(Event.timelineGenerated)
                        .catch { _ in Just(Event.failedToGenerateTimeline) }
                        .eraseToAnyPublisher()
                        .enqueue(to: consumer)
                }
                .start()
        }
    }

    static func whenUpdatingAsset(editor: VideoEditorProtocol) -> Feedback<State, Event> {
        .custom { state, consumer in
            state
                .map { $0.0 }
                .filter { .updatingAsset == $0.status }
                .flatMapLatest { state in
                    Future { promise in
                        do {
                            let result = try editor.apply(edit: state.videoEdit, to: state.originalAsset!)
                            promise(.success(result))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                    .eraseToAnyPublisher()
                    .receive(on: DispatchQueue.main)
                    .map(Event.assetEdited)
                    .catch { Just(Event.failedToEditAsset($0)) }
                    .eraseToAnyPublisher()
                    .enqueue(to: consumer)
                }
                .start()
        }
    }
}

// MARK: View Model

extension VideoEditorStore.State {
    var isSeeking: Bool {
        status == .seeking
    }

    var isTrimming: Bool {
        if case .trimming = status {
            return true
        }

        return false
    }

    func trimMarkerPosition(for side: VideoEditorStore.Side) -> Double {
        switch side {
        case .left:
            return leftHandTrimMarkerPosition
        case .right:
            return rightHandTrimMarkerPosition
        }
    }

    var editedItem: AVPlayerItem? {
        guard let editedAsset = editedAsset else { return nil }
        let item = AVPlayerItem(asset: editedAsset)
        item.videoComposition = videoComposition
        return item
    }

    var duration: CMTime {
        editedAsset != nil ? editedAsset!.duration : .zero
    }

    var timescale: CMTimeScale {
        duration.timescale
    }

    var aspectRatio: CGFloat {
        guard let editedAsset = editedAsset,
              let track = editedAsset.tracks(withMediaType: AVMediaType.video).first else {
            return .zero
        }

        let assetSize = track.naturalSize.applying(track.preferredTransform)

        return abs(assetSize.width) / abs(assetSize.height)
    }

    func numberOfFrames(within bounds: CGRect) -> Int {
        let frameWidth = bounds.height * aspectRatio
        return Int(bounds.width / frameWidth) + 1
    }

    var videoEdit: VideoEdit {
        var edit = VideoEdit()
        edit.speedRate = speedRate
        edit.trimPositions = (
            CMTime(seconds: duration.seconds * leftHandTrimMarkerPosition, preferredTimescale: timescale),
            CMTime(seconds: duration.seconds * rightHandTrimMarkerPosition, preferredTimescale: timescale)
        )
        edit.croppingPreset = croppingPreset
        return edit
    }
}
