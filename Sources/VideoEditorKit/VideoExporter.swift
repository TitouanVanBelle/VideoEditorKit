//
//  VideoExporter.swift
//  
//
//  Created by Titouan Van Belle on 07.11.20.
//

import AVFoundation
import Foundation

protocol VideoExporterProtocol {
    func export(asset: AVAsset, to url: URL, videoComposition: AVVideoComposition?)
}

final class VideoExporter: VideoExporterProtocol {
    func export(asset: AVAsset, to url: URL, videoComposition: AVVideoComposition?) {
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = url
        exporter?.outputFileType = .mov
        exporter?.videoComposition = videoComposition

        exporter?.exportAsynchronously(completionHandler: {
            if let error = exporter?.error {
                print(error)
                return
            }

            print("Saved")
        })
    }
}
