//
//  Slider.swift
//  
//
//  Created by Titouan Van Belle on 16.09.20.
//

import Combine
import UIKit

final class Slider: UIControl {
    
    // MARK: Public Properties

    @Published var isUpdating: Bool = false
    
    @Published var value: CGFloat = 0.0 {
        didSet {
            internalValue = value
        }
    }

    var minimumValue: CGFloat = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: CGFloat = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
     var isContinuous: Bool = true

    // MARK: Private Properties

    private let margin: CGFloat = 10.0
    
    private lazy var backgroundLayer: CALayer = makeBackgroundLayer()
    private lazy var trackerLayer: CALayer = makeTrackerLayer()
    private lazy var currentValueLabel: UILabel = makeCurrentValueLabel()
    private lazy var minimumValueLabel: UILabel = makeMinimumValueLabel()
    private lazy var maximumValueLabel: UILabel = makeMaximumValueLabel()

    private var previousLocation = CGPoint()
    private var internalValue: CGFloat = 0.0 {
        didSet {
            updateCurrentValueLabel()
            updateLayerFrames()
        }
    }
    
    // MARK: Init
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(trackerLayer)

        addSubview(currentValueLabel)
        addSubview(minimumValueLabel)
        addSubview(maximumValueLabel)

        updateLayerFrames()
        updateMaximumValueLabel()
        updateMinimumValueLabel()
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isUpdating = true
        previousLocation = touch.location(in: self)
        return trackerLayer.frame.contains(previousLocation)
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        previousLocation = location
        let temp = internalValue + deltaValue

        internalValue = bound(temp, toLowerValue: minimumValue, upperValue: maximumValue)

        if isContinuous {
            value = internalValue
        }

        sendActions(for: .valueChanged)
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        value = internalValue
        isUpdating = false
    }
    
    private func bound(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        min(max(value, lowerValue), upperValue)
    }
}

fileprivate extension Slider {
    func updateCurrentValueLabel() {
        currentValueLabel.text = String(format: "%.1f", internalValue)
    }

    func updateMinimumValueLabel() {
        minimumValueLabel.text = String(format: "%.1f", minimumValue)
    }

    func updateMaximumValueLabel() {
        maximumValueLabel.text = String(format: "%.1f", maximumValue)
    }

    func updateLayerFrames() {
        guard maximumValue != minimumValue else {
            fatalError("Maximum and minimum values cannot be the same")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let newOrigin = CGPoint(
            x: (bounds.width - 2 * margin) * ((internalValue - minimumValue) / (maximumValue - minimumValue)) - trackerLayer.frame.width / 2 + margin,
            y: (bounds.height - trackerLayer.frame.width) / 2
        )
        
        trackerLayer.frame = CGRect(origin: newOrigin, size: trackerLayer.frame.size)
        var frame = trackerLayer.frame
        frame.origin.y -= 30
        currentValueLabel.frame = frame
        CATransaction.commit()
    }
    
    func makeBackgroundLayer() -> CALayer {
        let layer = CALayer()
        let height: CGFloat = 8.0
        layer.frame = CGRect(
            x: 0 + margin,
            y: (bounds.height - height) / 2,
            width: bounds.width - 2 * margin,
            height: height
        )
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = height / 2
        return layer
    }
    
    func makeTrackerLayer() -> CALayer {
        let layer = CALayer()
        let side: CGFloat = 32.0
        layer.frame = CGRect(
            x: 0 - side / 2,
            y: (bounds.height - side) / 2,
            width: side,
            height: side
        )
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = side / 2
        return layer
    }

    func makeCurrentValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0, weight: .bold)
        label.textColor = .primaryForeground
        label.textAlignment = .center
        return label
    }

    func makeMinimumValueLabel() -> UILabel {
        let label = UILabel()
        label.frame = CGRect(
            x: 0 - 25 + margin,
            y: bounds.height / 2 + 20,
            width: 50,
            height: 24.0
        )
        label.font = .systemFont(ofSize: 13.0, weight: .regular)
        label.textColor = .primaryForeground
        label.textAlignment = .center
        return label
    }

    func makeMaximumValueLabel() -> UILabel {
        let label = UILabel()
        label.frame = CGRect(
            x: bounds.width - 50 + 25 - margin,
            y: bounds.height / 2 + 20,
            width: 50,
            height: 24.0
        )
        label.font = .systemFont(ofSize: 13.0, weight: .regular)
        label.textColor = .primaryForeground
        label.textAlignment = .center
        return label
    }
}
