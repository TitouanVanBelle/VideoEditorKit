//
//  TimelineView.swift
//  
//
//  Created by Titouan Van Belle on 17.09.20.
//

import UIKit

final class VideoTimelineView: UIView {

    // MARK: Public Properties

    public var isConfigured: Bool = false

    // MARK: Init

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public

extension VideoTimelineView {
    func configure(with frames: [CGImage], assetAspectRatio: CGFloat) {
        let width = bounds.height * assetAspectRatio

        frames.enumerated().forEach {
            let imageView = UIImageView()
            imageView.image = UIImage(cgImage: $0.1, scale: 1.0, orientation: .up)
            addSubview(imageView)

            imageView.autoPinEdge(toSuperviewEdge: .top)
            imageView.autoPinEdge(toSuperviewEdge: .bottom)
            imageView.autoMatch(.height, to: .height, of: self)
            imageView.autoSetDimension(.width, toSize: width)

            if $0.0 == 0 {
                imageView.autoPinEdge(toSuperviewEdge: .left)
            } else {
                let previousImageView = subviews[$0.0 - 1]
                imageView.autoPinEdge(.left, to: .right, of: previousImageView)
            }
        }

        isConfigured = true
    }
}

// MARK: UI

fileprivate extension VideoTimelineView {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        clipsToBounds = true
    }

    func setupConstraints() {

    }
}

