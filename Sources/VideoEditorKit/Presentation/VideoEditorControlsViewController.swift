//
//  VideoEditorControlsViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import Combine
import PureLayout
import UIKit

final class VideoEditorControlsViewController: UIViewController {

    // MARK: Public Properties

    @Published public var nextScrubberPosition: Double = 0.0

    // MARK: Private Properties

    private lazy var tabsViewController: TabsViewController = makeTabsViewController()
    private lazy var croppingControlViewController: CroppingControlViewController = makeCroppingControlViewController()
    private lazy var videoSpeedControlViewController: VideoSpeedControlViewController = makeVideoSpeedControlViewController()
    private lazy var trimmingControlViewController: TrimmingControlViewController = makeTrimmingControlViewController()

    private var cancellables = Set<AnyCancellable>()

    private let store: VideoEditorStore
    private let viewFactory: InternalVideoEditorViewFactoryProtocol

    // MARK: Init

    init(store: VideoEditorStore, viewFactory: InternalVideoEditorViewFactoryProtocol) {
        self.store = store
        self.viewFactory = viewFactory

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: UI

fileprivate extension VideoEditorControlsViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        add(tabsViewController)
    }

    func setupConstraints() {
        tabsViewController.view.autoPinEdgesToSuperviewSafeArea()
    }

    func makeTabsViewController() -> TabsViewController {
        TabsViewController(viewControllers: [
            trimmingControlViewController,
            videoSpeedControlViewController,
            croppingControlViewController
        ])
    }

    func makeCroppingControlViewController() -> CroppingControlViewController {
        viewFactory.makeCroppingControlViewController()
    }

    func makeVideoSpeedControlViewController() -> VideoSpeedControlViewController {
        viewFactory.makeVideoSpeedControlViewController()
    }

    func makeTrimmingControlViewController() -> TrimmingControlViewController {
        viewFactory.makeTrimmingControlViewController()
    }
}
