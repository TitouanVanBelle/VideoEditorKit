//
//  DateComponentsFormatter+TimeFormatters.swift
//  
//
//  Created by Titouan Van Belle on 26.10.20.
//

import Foundation

extension DateComponentsFormatter {
    static var shortDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()

    static var longDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()
}
