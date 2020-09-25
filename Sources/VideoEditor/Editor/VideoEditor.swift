//
//  VideoEditor.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import AVFoundation
import Combine
import Foundation

enum VideoEditorError: Error {
    case unknown
}

protocol VideoEditorProtocol {
    func apply(edit: VideoEdit, to asset: AVAsset) -> AnyPublisher<AVAsset, VideoEditorError>
}

final class VideoEditor: VideoEditorProtocol {

    // MARK: Init

    init() {}

    func apply(edit: VideoEdit, to asset: AVAsset) -> AnyPublisher<AVAsset, VideoEditorError> {
        Future { promise in
            let composition = AVMutableComposition()
            guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                  let track = asset.tracks(withMediaType: .video).first else {
                print("Failed to apply video edit \(self)")
                promise(.failure(VideoEditorError.unknown))
                return
            }

            let originalDuration = asset.duration
            let originalDurationSeconds = originalDuration.seconds
            let timescale = originalDuration.timescale
            let start = CMTime(seconds: edit.trim.0 * originalDurationSeconds, preferredTimescale: timescale)
            let duration = CMTime(seconds: (edit.trim.1 - edit.trim.0) * originalDurationSeconds, preferredTimescale: timescale)
            let range = CMTimeRange(start: start, duration: duration)

            do {
                try compositionTrack.insertTimeRange(range, of: track, at: .zero)

                let newDuration = Double(duration.seconds) / edit.speed
                let time = CMTime(seconds: newDuration, preferredTimescale: duration.timescale)
                let newRange = CMTimeRange(start: .zero, duration: duration)
                compositionTrack.scaleTimeRange(newRange, toDuration: time)
                compositionTrack.preferredTransform = track.preferredTransform
            } catch {
                promise(.failure(VideoEditorError.unknown))
            }

            promise(.success(composition))
        }.eraseToAnyPublisher()
    }
}
