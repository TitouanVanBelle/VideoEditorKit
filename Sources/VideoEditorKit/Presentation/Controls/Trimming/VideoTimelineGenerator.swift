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
    func generateTimeline(for asset: AVAsset, within bounds: CGRect, count: Int) -> AnyPublisher<[CGImage], Error>
}

final class VideoTimelineGenerator: VideoTimelineGeneratorProtocol {

    init() {}

    func generateTimeline(for asset: AVAsset, within bounds: CGRect, count: Int) -> AnyPublisher<[CGImage], Error> {
        let generator = AVAssetImageGenerator(asset: asset)
        var images = [CGImage]()
        return Future { promise in

            let times = self.getTimesOfThumnails(for: asset, count: count)

            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = .zero // TODO

            generator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let cgImage = cgImage {
                    images.append(cgImage)
                    if images.count == count {
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
    func getTimesOfThumnails(for asset: AVAsset, count: Int) -> [NSValue] {
        let timeIncrement = (asset.duration.seconds * 1000) / Double(count)
        var timesForThumbnails = [NSValue]()

        for index in 0..<count {
            let cmTime = CMTime(value: Int64(timeIncrement * Float64(index)), timescale: 1000)
            let nsValue = NSValue(time: cmTime)
            timesForThumbnails.append(nsValue)
        }

        return timesForThumbnails
    }
}
