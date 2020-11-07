//
//  VideoEdit+Lenses.swift
//  
//
//  Created by Titouan Van Belle on 06.11.20.
//

import CoreMedia
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

    static let trimPositionsLens = Lens<VideoEdit, (CMTime, CMTime)?>(
        from: { $0.trimPositions },
        to: { trimPositions, previousEdit in
            var edit = VideoEdit()
            edit.croppingPreset = previousEdit.croppingPreset
            edit.speedRate = previousEdit.speedRate
            edit.trimPositions = trimPositions
            return edit
        }
    )

    static let croppingPresetLens = Lens<VideoEdit, CroppingPreset?>(
        from: { $0.croppingPreset },
        to: { croppingPreset, previousEdit in
            var edit = VideoEdit()
            edit.croppingPreset = croppingPreset
            edit.speedRate = previousEdit.speedRate
            edit.trimPositions = previousEdit.trimPositions
            return edit
        }
    )
}


