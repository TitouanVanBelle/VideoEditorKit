//
//  VideoEdit+Lenses.swift
//  
//
//  Created by Titouan Van Belle on 06.11.20.
//

import Foundation
import VideoEditor

extension VideoEdit {
    static let speedRateLens = Lens<VideoEdit, Double>(
        from: { $0.speedRate },
        to: { speedRate, previousEdit in
            var edit = VideoEdit()
            edit.croppingPreset = previousEdit.croppingPreset
            edit.speedRate = speedRate
            edit.trimPositions = previousEdit.trimPositions
            return edit
        }
    )
}
