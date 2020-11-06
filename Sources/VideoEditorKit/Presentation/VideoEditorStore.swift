//
//  VideoEditorStore.swift
//  
//
//  Created by Titouan Van Belle on 28.10.20.
//

import AVFoundation
import Combine
import Foundation
import VideoEditor

extension VideoEditResult {
    var item: AVPlayerItem {
        let item = AVPlayerItem(asset: asset)
//        item.videoComposition = videoComposition
        return item
    }
}

final class VideoEditorStore {

    // MARK: Public Properties

    @Published private(set) var originalAsset: AVAsset

    @Published var editedPlayerItem: AVPlayerItem

    @Published var playheadProgress: CMTime = .zero

    @Published var isSeeking: Bool = false
    @Published var currentSeekingValue: Double = .zero

    @Published var speed: Double = 1.0

    @Published var videoEdit: VideoEdit

    var currentSeekingTime: CMTime {
        CMTime(seconds: duration.seconds * currentSeekingValue, preferredTimescale: duration.timescale)
    }

    var assetAspectRatio: CGFloat {
        guard let track = editedPlayerItem.asset.tracks(withMediaType: AVMediaType.video).first else {
            return .zero
        }

        let assetSize = track.naturalSize.applying(track.preferredTransform)

        return abs(assetSize.width) / abs(assetSize.height)
    }

    var duration: CMTime {
        editedPlayerItem.asset.duration
    }

    var fractionCompleted: Double {
        guard duration != .zero else {
            return .zero
        }

        return playheadProgress.seconds / duration.seconds
    }

    // MARK: Private Properties

    private var cancellables = Set<AnyCancellable>()

    private let editor: VideoEditor
    private let generator: VideoTimelineGeneratorProtocol

    // MARK: Init

    init(
        asset: AVAsset,
        editor: VideoEditor = .init(),
        generator: VideoTimelineGeneratorProtocol = VideoTimelineGenerator()
    ) {
        self.originalAsset = asset
        self.editor = editor
        self.generator = generator

        var videoEdit = VideoEdit()
        videoEdit.speedRate = 1.0

        let result = try! self.editor.apply(edit: videoEdit, to: asset)
        self.editedPlayerItem = result.item
        self.videoEdit = videoEdit

        setupBindings()
    }
}

// MARK: Bindings

fileprivate extension VideoEditorStore {
    func setupBindings() {
        $videoEdit
            .compactMap { [weak self] edit -> VideoEditResult? in
                guard let self = self else { return nil }
                return try? self.editor.apply(edit: edit, to: self.originalAsset)
            }
            .map(\.item)
            .assign(to: \.editedPlayerItem, weakly: self)
            .store(in: &cancellables)

        $speed
            .filter { [weak self] speed in
                guard let self = self else { return false }
                return speed != self.videoEdit.speedRate
            }
            .compactMap { [weak self] speedRate in
                guard let self = self else { return nil }
                return VideoEdit.speedRateLens.to(speedRate, self.videoEdit)
            }
            .assign(to: \.videoEdit, weakly: self)
            .store(in: &cancellables)
    }
}

extension VideoEditorStore {
    func videoTimeline(for bounds: CGRect) -> AnyPublisher<[CGImage], Error> {
        generator.generateTimeline(for: originalAsset, within: bounds, count: numberOfFrames(within: bounds))
    }
}

fileprivate extension VideoEditorStore {
    func numberOfFrames(within bounds: CGRect) -> Int {
        let frameWidth = bounds.height * assetAspectRatio
        return Int(bounds.width / frameWidth) + 1
    }
}

