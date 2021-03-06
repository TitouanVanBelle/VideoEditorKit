//
//  Slider.swift
//  
//
//  Created by Titouan Van Belle on 16.09.20.
//

// TODO
// - Round up before checking if haptic should be played

import Combine
import UIKit

final class Slider: UIControl {

    // MARK: Constants

    enum Constants {
        static let height: CGFloat = 34.0
        static let trackerInnerCircleHeight: CGFloat = 16.0
        static let trackerOutterCircleHeight: CGFloat = 32.0
        static let trackerHorizontalMargin: CGFloat = 1.0
        static let indicatorHeight: CGFloat = 4.0

        static let backgroundColor: CGColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1).cgColor
        static let trackOutterCircleBackgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1).cgColor
        static let trackerInnerCircleBackgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1).cgColor
        static let indicatorsBackgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1).cgColor

        static let currentValueFont: UIFont = .systemFont(ofSize: 15.0, weight: .medium)
    }

    // MARK: Inner Types

    enum Range {
        case linear(min: Double, max: Double)
        case stepped(values: [Double])

        var values: [Double] {
            switch self {
            case .linear(let min, let max):
                return [min, max]

            case .stepped(let values):
                return values
            }
        }
    }
    
    // MARK: Public Properties

    var isContinuous: Bool = true

    @Published var isDragging: Bool = false
    
    @Published var value: Double = .zero

    var range: Range = .linear(min: 0.0, max: 1.0) {
        didSet { setNeedsDisplay() }
    }

    override var frame: CGRect {
        didSet {
            updateTrackerLayerFrames()
        }
    }

    // MARK: Private Properties

    @Published private var xPosition: CGFloat = Constants.trackerHorizontalMargin

    @Published var internalValue: Double = .zero

    private var hapticFeedbackLayers: [CALayer] = []

    private lazy var backgroundLayer: CALayer = makeBackgroundLayer()
    private lazy var trackerInnerCircleLayer: CALayer = makeTrackerInnerCircleLayer()
    private lazy var trackerOutterCircleLayer: CALayer = makeTrackerOutterCircleLayer()
    private lazy var currentValueLabel: UILabel = makeCurrentValueLabel()
    private lazy var valuesStackView: UIStackView = makeValuesStackView()

    private var cancellables = Set<AnyCancellable>()

    private let hapticGenerator = UIImpactFeedbackGenerator()
    
    // MARK: Init
    
    public init() {
        super.init(frame: .zero)

        setupBindings()

        hapticGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(trackerOutterCircleLayer)
        trackerOutterCircleLayer.addSublayer(trackerInnerCircleLayer)

        addSubview(currentValueLabel)
        addSubview(valuesStackView)

        xPosition = xPosition(forValue: value)

        updateTrackerLayerFrames()
        positionValues()
        positionHapticIndicators()
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isDragging = true
        return true
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        xPosition = cappedXLocation(for: touch)
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch = touch {
            xPosition = cappedXLocation(for: touch)
        }

        value = internalValue

        isDragging = false
    }
}

// MARK: Bindings

fileprivate extension Slider {
    func setupBindings() {
        $xPosition
            .map(value(forXPosition:))
            .assign(to: \.internalValue, weakly: self)
            .store(in: &cancellables)

        $xPosition
            .sink { [weak self] x in
                guard let self = self else { return }
                self.updateTrackerLayerFrames()
            }
            .store(in: &cancellables)

        $internalValue
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.isDragging && self.isContinuous
            }
            .assign(to: \.value, weakly: self)
            .store(in: &cancellables)

        $internalValue
            .map(formattedString(forValue:))
            .assign(to: \.text, weakly: currentValueLabel)
            .store(in: &cancellables)

        $internalValue
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                self.generateHapticFeedbackIfNeeded(for: value)
            }
            .store(in: &cancellables)

        $value
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.isDragging
            }
            .sink { [weak self] value in
                guard let self = self else { return }
                self.internalValue = value
                self.xPosition = self.xPosition(forValue:value)
            }
            .store(in: &cancellables)
    }

    func generateHapticFeedbackIfNeeded(for value: Double) {
        if range.values.contains(value) {
            hapticGenerator.impactOccurred()
        }
    }
}

// MARK: Helpers

fileprivate extension Slider {
    func cappedXLocation(for touch: UITouch) -> CGFloat {
        let location = touch.location(in: self)
        let x = location.x - Constants.trackerOutterCircleHeight / 2
        let horizontalMargin: CGFloat = 1.0
        let minValue: CGFloat = horizontalMargin
        let maxValue = bounds.width - 2 * Constants.trackerOutterCircleHeight / 2 - horizontalMargin
        let cappedX = min(max(x, minValue), maxValue)

        return cappedX
    }

    func value(forXPosition xPosition: CGFloat) -> Double {
        switch range {
        case .linear(let min, let max):
            return value(forXPosition: xPosition, between: min, and: max)
        case .stepped(let values):
            return value(forXPosition: xPosition, in: values)
        }
    }

    func value(forXPosition xPosition: CGFloat, between min: Double, and max: Double) -> Double {
        let scaledPosition = xPosition - Constants.trackerHorizontalMargin
        let width = bounds.width - Constants.trackerOutterCircleHeight - 2 * Constants.trackerHorizontalMargin
        return Double(scaledPosition / width) * (max - min) + min
    }

    func value(forXPosition xPosition: CGFloat, in values: [Double]) -> Double {
        let width = bounds.width - Constants.trackerOutterCircleHeight - 2 * Constants.trackerHorizontalMargin
        let progress = xPosition / width
        let step = (CGFloat(1) / CGFloat((values.count - 1)))
        let index = Int(floor(progress / step))

        if index == values.count - 1 {
            return values[index]
        } else {
            let min = values[index]
            let max = values[index + 1]
            let value = min + (max - min) * ((Double(progress) - Double(index) * Double(step)) / Double(step))
            return value
        }
    }

    func xPosition(forValue value: Double) -> CGFloat {
        switch range {
        case .linear(let min, let max):
            return xPosition(forValue: value, between: min, and: max)
        case .stepped(let values):
            return xPosition(forValue: value, in: values)
        }
    }

    func xPosition(forValue value: Double, between min: Double, and max: Double) -> CGFloat {
        let width = bounds.width - Constants.trackerOutterCircleHeight - 2 * Constants.trackerHorizontalMargin

        let xPosition = CGFloat((value - min) / (max - min)) * width + Constants.trackerHorizontalMargin
        return xPosition
    }

    func xPosition(forValue value: Double, in values: [Double]) -> CGFloat {
        let width = bounds.width - Constants.trackerOutterCircleHeight - 2 * Constants.trackerHorizontalMargin
        let segment = width / CGFloat(values.count - 1)

        if let index = values.firstIndex(of: value) {
            let xPosition = CGFloat(index) * segment
            return xPosition
        }

        let index = values.firstIndex(where: { $0 > value })! - 1
        let min = CGFloat(values[index])
        let max = CGFloat(values[index + 1])
        let xPosition = CGFloat(index - 1) * segment + (max - min) * (max - CGFloat(value))
        return xPosition
    }

    func formattedString(forValue value: Double) -> String {
        if value < 1.0 {
            return String(format: "%.2fx", value)
        } else if value < 10.0 {
            return String(format: "%.1fx", value)
        } else {
            return String(format: "%.0fx", value)
        }
    }
}

// MARK: UI

fileprivate extension Slider {
    func positionValues() {
        range.values
            .map(makeValueLabel(for:))
            .forEach(addSubview)
    }

    func positionHapticIndicators() {
        range.values
            .map(makeHapticIndicatorLayer(for:))
            .forEach(backgroundLayer.addSublayer)
    }

    func updateTrackerLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let newOrigin = CGPoint(
            x: xPosition,
            y: (bounds.height - trackerOutterCircleLayer.frame.width) / 2
        )
        
        trackerOutterCircleLayer.frame = CGRect(origin: newOrigin, size: trackerOutterCircleLayer.frame.size)
        var frame = trackerOutterCircleLayer.frame
        frame.origin.y -= 40
        frame.origin.x -= (100.0 - frame.size.width) / 2
        frame.size.width = 100.0
        currentValueLabel.frame = frame
        CATransaction.commit()
    }
    
    func makeBackgroundLayer() -> CALayer {
        let layer = CALayer()
        let height = Constants.height
        layer.frame = CGRect(
            x: 0,
            y: (bounds.height - height) / 2,
            width: bounds.width,
            height: height
        )
        layer.backgroundColor = Constants.backgroundColor
        layer.cornerRadius = height / 2
        return layer
    }
    
    func makeTrackerInnerCircleLayer() -> CALayer {
        let layer = CALayer()
        let side: CGFloat = Constants.trackerInnerCircleHeight
        layer.frame = CGRect(
            x: (Constants.trackerOutterCircleHeight - side) / 2,
            y: (Constants.trackerOutterCircleHeight - side) / 2,
            width: side,
            height: side
        )
        layer.backgroundColor = Constants.trackerInnerCircleBackgroundColor
        layer.cornerRadius = side / 2
        return layer
    }

    func makeTrackerOutterCircleLayer() -> CALayer {
        let layer = CALayer()
        let side: CGFloat = Constants.trackerOutterCircleHeight
        layer.frame = CGRect(
            x: 0 - side / 2,
            y: (bounds.height - side) / 2,
            width: side,
            height: side
        )
        layer.backgroundColor = Constants.trackOutterCircleBackgroundColor
        layer.cornerRadius = side / 2
        return layer
    }

    func makeCurrentValueLabel() -> UILabel {
        let label = UILabel()
        label.font = Constants.currentValueFont
        label.textColor = .foreground
        label.textAlignment = .center
        return label
    }

    func makeValuesStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.frame = CGRect(
            x: Constants.trackerOutterCircleHeight / 2,
            y: bounds.midY + Constants.height / 2,
            width: bounds.width - Constants.trackerOutterCircleHeight,
            height: 34.0
        )
        return stack
    }

    func makeHapticIndicatorLayer(for value: Double) -> CALayer {
        let layer = CALayer()
        let y = (Constants.height - Constants.indicatorHeight) / 2
        let x = xPosition(forValue: value) + Constants.trackerOutterCircleHeight / 2 - Constants.indicatorHeight / 2
        layer.frame = CGRect(
            x: x,
            y: y,
            width: Constants.indicatorHeight,
            height: Constants.indicatorHeight
        )
        layer.cornerRadius = Constants.indicatorHeight / 2
        layer.backgroundColor = Constants.indicatorsBackgroundColor
        return layer
    }

    func makeValueLabel(for value: Double) -> UILabel {
        let label = UILabel()
        if value < 1.0 {
            label.text = String(format: "%.2fx", value)
        } else {
            label.text = String(format: "%.0fx", value)
        }

        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11.0)

        label.sizeToFit()

        let y = bounds.midY + Constants.height / 2
        let x = xPosition(forValue: value) + (Constants.trackerOutterCircleHeight - label.frame.width) / 2
        label.frame = CGRect(
            x: x,
            y: y,
            width: label.frame.width,
            height: 34.0
        )

        return label
    }
}
