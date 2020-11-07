//
//  FrameGenerator.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import AVFoundation
import Combine
import Foundation

protocol VideoTimelineGeneratorProtocol {
    func videoTimeline(for asset: AVAsset, in bounds: CGRect, numberOfFrames: Int) -> AnyPublisher<[CGImage], Error>
}

final class VideoTimelineGenerator: VideoTimelineGeneratorProtocol {

    func videoTimeline(for asset: AVAsset, in bounds: CGRect, numberOfFrames: Int) -> AnyPublisher<[CGImage], Error> {
        Future { promise in

            let generator = AVAssetImageGenerator(asset: asset)
            var images = [CGImage]()
            let times = self.frameTimes(for: asset, numberOfFrames: numberOfFrames)

            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = .zero // TODO

            generator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let cgImage = cgImage {
                    images.append(cgImage)
                    if images.count == numberOfFrames {
                        promise(.success(images))
                    }
                } else {
                    fatalError("Error while generating CGImages")
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

fileprivate extension VideoTimelineGenerator {
    func frameTimes(for asset: AVAsset, numberOfFrames: Int) -> [NSValue] {
        let timeIncrement = (asset.duration.seconds * 1000) / Double(numberOfFrames)
        var timesForThumbnails = [CMTime]()

        for index in 0..<numberOfFrames {
            let cmTime = CMTime(value: Int64(timeIncrement * Float64(index)), timescale: 1000)
            timesForThumbnails.append(cmTime)
        }

        return timesForThumbnails.map(NSValue.init)
    }
}
