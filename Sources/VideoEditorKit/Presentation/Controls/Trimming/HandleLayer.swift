//
//  HandleLayer.swift
//  
//
//  Created by Titouan Van Belle on 17.09.20.
//

import UIKit

final class HandleLayer: CALayer {

    enum Side {
        case left
        case right

        var imageName: String {
            switch self {
            case .right:
                return "RightArrow"
            case .left:
                return "LeftArrow"
            }
        }
    }

    private lazy var imageLayer: CALayer = makeImageLayer()
    private let side: Side

    init(side: Side) {
        self.side = side

        super.init()

        backgroundColor = UIColor.primaryForeground.cgColor
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        addSublayer(imageLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeImageLayer() -> CALayer {
        let layer = CALayer()
        let image = UIImage(named: side.imageName, in: .module, compatibleWith: nil)!.cgImage
        layer.frame = CGRect(x: 0, y: 0, width: 6, height: 16)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        let maskLayer = CALayer()
        maskLayer.frame = layer.bounds
        maskLayer.contents = image
        maskLayer.contentsGravity = .resizeAspect
        layer.mask = maskLayer
        layer.backgroundColor = UIColor.secondaryBackground.withAlphaComponent(0.3).cgColor

        return layer
    }
}
