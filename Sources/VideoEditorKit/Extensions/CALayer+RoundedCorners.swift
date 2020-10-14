//
//  CALayer+RoundedCourners.swift
//  
//
//  Created by Titouan Van Belle on 17.09.20.
//

import UIKit

extension CALayer {
    func roundCorners(_ radius: CGFloat, _ corners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.mask = mask
    }
}
