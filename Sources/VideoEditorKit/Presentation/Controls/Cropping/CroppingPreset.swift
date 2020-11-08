//
//  CroppingPresetCellViewModel.swift
//  
//
//  Created by Titouan Van Belle on 09.10.20.
//

import Foundation
import VideoEditor

final class CroppingPresetCellViewModel: NSObject {

    // MARK: Public Properties

    let croppingPreset: CroppingPreset

    // MARK: Init

    init(croppingPreset: CroppingPreset) {
        self.croppingPreset = croppingPreset
    }

    // MARK: Public Properties

    var ratio: Double {
        switch croppingPreset {
        case .vertical:
            return 3 / 4
        case .standard:
            return 4 / 3
        case .portrait:
            return 9 / 16
        case .square:
            return 1 / 1
        case .landscape:
            return 16 / 9
        case .instagram:
            return 4 / 5
        }
    }

    var formattedRatio: String {
        switch croppingPreset {
        case .vertical:
            return "3:4"
        case .standard:
            return "4:3"
        case .portrait:
            return "9:16"
        case .square:
            return "1:1"
        case .landscape:
            return "16:9"
        case .instagram:
            return "4:5"
        }
    }

    var name: String {
        switch croppingPreset {
        case .vertical:
            return "Vertical"
        case .standard:
            return "Standard"
        case .portrait:
            return "Portrait"
        case .square:
            return "Square"
        case .landscape:
            return "Landscape"
        case .instagram:
            return "Instagram"
        }
    }

    var imageName: String {
        "CroppingPresets/\(name)"
    }
}
