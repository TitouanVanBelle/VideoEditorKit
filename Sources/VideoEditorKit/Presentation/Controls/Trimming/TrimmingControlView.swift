//
//  VideoTimeline.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import AVFoundation
import PureLayout
import UIKit

public class TrimmingControlView: UIControl {

    // MARK: Public Properties

    @Published var isSeeking: Bool = false
    @Published var isTrimming: Bool = false

    @Published var seekerValue: CGFloat = 0.0 {
        didSet {
            updateSeekerFrame()
        }
    }

    @Published public var leftTrimValue: CGFloat = 0.0 {
        didSet {
            updateLeftHandleFrame()
        }
    }

    @Published public var rightTrimValue: CGFloat = 1.0 {
        didSet {
            updateRightHandleFrame()
        }
    }

    public override var bounds: CGRect {
        didSet {
            updateSeekerFrame()
            updateLeftHandleFrame()
            updateRightHandleFrame()
        }
    }

    public var isConfigured: Bool = false

    public func setSeekerValue(_ value: Double) {
        seekerValue = CGFloat(value)
    }

    // MARK: Private Properties

    private var handleWidth: CGFloat = 20.0

    private var isLeftHandleHighlighted = false
    private var isRightHandleHighlighted = false

    private var leftHandleMinX: CGFloat {
        leftHandle.frame.minX
    }

    private var rightHandleMaxX: CGFloat {
        rightHandle.frame.maxX
    }

    private lazy var seeker: CALayer = makeSeeker()
    private lazy var rightHandle: CALayer = makeRightHandle()
    private lazy var leftHandle: CALayer = makeLeftHandle()
    private lazy var rightDimmedBackground: CALayer = makeRightDimmedBackground()
    private lazy var leftDimmedBackground: CALayer = makeLeftDimmedBackground()
    private lazy var timeline: VideoTimelineView = makeVideoTimeline()

    // MARK: Init

    init() {
        super.init(frame: .zero)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        if leftHandle.frame.contains(location) {
            isTrimming = true
            isLeftHandleHighlighted = true
            seeker.isHidden = true
        } else if rightHandle.frame.contains(location) {
            isTrimming = true
            isRightHandleHighlighted = true
            seeker.isHidden = true
        } else {
            isSeeking = true
            seekerValue = boundedSeekerValue(seekerPosition: location.x)
        }

        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        if isLeftHandleHighlighted {
            leftTrimValue = self.leftHandleValue(for: location.x)
        } else if isRightHandleHighlighted {
            rightTrimValue = self.rightHandleValue(for: location.x)
        } else {
            seekerValue = boundedSeekerValue(seekerPosition: location.x)
        }

        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        seeker.isHidden = false
        isLeftHandleHighlighted = false
        isRightHandleHighlighted = false
        isTrimming = false
        isSeeking = false
    }
}

// MARK: Control Helpers

fileprivate extension TrimmingControlView {
    func leftHandleValue(for x: CGFloat) -> CGFloat {
        min(1.0, max(0.0, x / bounds.width))
    }

    func rightHandleValue(for x: CGFloat) -> CGFloat {
        min(1.0, max(0.0, x / bounds.width))
    }

    func boundedSeekerValue(seekerPosition: CGFloat) -> CGFloat {
        if (rightHandleMaxX - leftHandleMinX) == .zero {
            return .zero
        }

        return (seekerPosition - leftHandleMinX) / (rightHandleMaxX - leftHandleMinX)
    }
}

// MARK: UI

extension TrimmingControlView {
    func configure(with frames: [CGImage], assetAspectRatio: CGFloat) {
        timeline.configure(with: frames, assetAspectRatio: assetAspectRatio)
        isConfigured = true
    }
}

// MARK: UI

fileprivate extension TrimmingControlView {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        layer.cornerRadius = 8.0
        clipsToBounds = true

        addSubview(timeline)

        layer.addSublayer(leftDimmedBackground)
        layer.addSublayer(rightDimmedBackground)
        layer.addSublayer(seeker)
        layer.addSublayer(leftHandle)
        layer.addSublayer(rightHandle)
    }

    func setupConstraints() {
        timeline.autoPinEdgesToSuperviewEdges()
    }

    func updateLeftHandleFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        leftHandle.frame = CGRect(
            x: bounds.width * leftTrimValue,
            y: 0,
            width: handleWidth,
            height: bounds.height
        )

        leftHandle.roundCorners(8.0, [.topLeft, .bottomLeft])

        leftDimmedBackground.frame = CGRect(
            x: 0,
            y: 0,
            width: leftHandle.frame.maxX,
            height: bounds.height
        )

        CATransaction.commit()
    }

    func updateRightHandleFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        rightHandle.frame = CGRect(
            x: bounds.width * rightTrimValue - handleWidth,
            y: 0,
            width: handleWidth,
            height: bounds.height
        )
        rightHandle.roundCorners(8.0, [.topRight, .bottomRight])

        rightDimmedBackground.frame = CGRect(
            x: rightHandle.frame.minX,
            y: 0,
            width: bounds.width - rightHandle.frame.minX,
            height: bounds.height
        )

        CATransaction.commit()
    }

    func updateSeekerFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let verticalMargin: CGFloat = 4.0
        let width: CGFloat = 2.0
        let x = leftHandleMinX + (rightHandleMaxX - leftHandleMinX - width / 2) * seekerValue
        seeker.frame = CGRect(
            x: x,
            y: 0 - verticalMargin,
            width: width,
            height: bounds.height + 2 * verticalMargin
        )

        CATransaction.commit()
    }

    func makeVideoTimeline() -> VideoTimelineView {
        let view = VideoTimelineView()
        return view
    }

    func makeSeeker() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 3.0
        return layer
    }

    func makeRightHandle() -> CALayer {
        HandleLayer(side: .right)
    }

    func makeLeftHandle() -> CALayer {
        HandleLayer(side: .left)
    }

    func makeRightDimmedBackground() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        return layer
    }

    func makeLeftDimmedBackground() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        return layer
    }
}

