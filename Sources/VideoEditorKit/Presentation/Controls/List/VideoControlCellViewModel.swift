//
//  VideoEditCellViewModel.swift
//  
//
//  Created by Titouan Van Belle on 27.10.20.
//

import Foundation

final class VideoControlCellViewModel: NSObject {

    let videoControl: VideoControl

    // MARK: Init

    init(videoControl: VideoControl) {
        self.videoControl = videoControl
    }

    var name: String {
        switch videoControl {
        case .speed:
            return "Speed"
        case .trim:
            return "Trim"
        case .crop:
            return "Crop"
        case .audio:
            return "Audio"
        }
    }

    var imageName: String {
        "VideoControls/\(name)"
    }
}
