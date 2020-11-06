//
//  SpeedVideoControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import Combine
import PureLayout
import UIKit

final class SpeedVideoControlViewController: UIViewController {

    // MARK: Public Properties

    @Published var speed: Double = 1.0

    @Published var isUpdating: Bool = false

    override var tabBarItem: UITabBarItem! {
        get {
            UITabBarItem(
                title: "Speed",
                image: UIImage(named: "Speed", in: .module, compatibleWith: nil),
                selectedImage: UIImage(named: "Speed-Selected", in: .module, compatibleWith: nil)
            )
        }
        set {}
    }

    // MARK: Private Properties

    private lazy var slider: Slider = makeSlider()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }
}

// MARK: Bindings

fileprivate extension SpeedVideoControlViewController {
    func setupBindings() {
        slider.$value
            .assign(to: \.speed, weakly: self)
            .store(in: &cancellables)
    }
}

// MARK: UI

fileprivate extension SpeedVideoControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(slider)
    }

    func setupConstraints() {
        let inset: CGFloat = 28.0

        slider.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
        slider.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
        slider.autoSetDimension(.height, toSize: 48.0)
        slider.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    func makeSlider() -> Slider {
        let slider = Slider()
        slider.value = 1.0
        slider.range = .stepped(values: [0.25, 0.5, 0.75, 1.0, 2.0, 5.0, 10.0])
        slider.isContinuous = false

        return slider
    }
}

