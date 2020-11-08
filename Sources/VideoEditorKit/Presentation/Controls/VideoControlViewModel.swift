//
//  File.swift
//  
//
//  Created by Titouan Van Belle on 29.10.20.
//

import Foundation

final class VideoControlViewModel {
    let videoControl: VideoControl

    var title: String {
        switch videoControl {
        case .speed:
            return "Speed"
        case .trim:
            return "Trim"
        case .crop:
            return "Crop"
        }
    }

    var titleImageName: String {
        "VideoControls/\(title)"
    }

    init(videoControl: VideoControl) {
        self.videoControl = videoControl
    }

}
