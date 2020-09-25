//
//  VideoSpeedControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import Combine
import PureLayout
import UIKit

final class VideoSpeedControlViewController: UIViewController {

    // MARK: Public Properties

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

    private let store: VideoEditorStore

    // MARK: Init

    init(store: VideoEditorStore) {
        self.store = store
        
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

fileprivate extension VideoSpeedControlViewController {
    func setupBindings() {
        slider.$value.sink { [weak self] speedRate in
            guard let self = self else { return }
            self.store.send(event: .updateSpeed(Double(speedRate)))
        }
        .store(in: &cancellables)
    }
}

// MARK: UI

fileprivate extension VideoSpeedControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
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
        slider.minimumValue = 0.5
        slider.value = CGFloat(store.state.speedRate)
        slider.maximumValue = 2.0
        slider.isContinuous = false
        return slider
    }
}
