//
//  TrimVideoControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import AVFoundation
import Combine
import PureLayout
import UIKit

final class TrimVideoControlViewController: UIViewController {

    // MARK: Public Properties

    override var tabBarItem: UITabBarItem! {
        get {
            UITabBarItem(
                title: "Trim",
                image: UIImage(named: "Trim", in: .module, compatibleWith: nil),
                selectedImage: UIImage(named: "Trim-Selected", in: .module, compatibleWith: nil)
            )
        }
        set {}
    }

    // MARK: Private Properties

    private lazy var trimmingControlView: TrimmingControlView = makeTrimmingControlView()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        store.videoTimeline(for: trimmingControlView.bounds)
//            .replaceError(with: [])
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] images in
//                guard let self = self else { return }
//                self.updateVideoTimeline(with: images, assetAspectRatio: self.store.assetAspectRatio)
//            }.store(in: &cancellables)
    }
}

// MARK: Bindings

fileprivate extension TrimVideoControlViewController {
    func setupBindings() {
//        store.$state.sink { [weak self] state in
//            guard let self = self else { return }
//
//            self.updateView(with: state.timeline, aspectRatio: state.aspectRatio)
//
//            if !self.trimmingControlView.isSeeking && !self.trimmingControlView.isTrimming {
//                self.updateSeekerPosition(progress: state.videoProgress)
//            }
//        }.store(in: &cancellables)
//
//        trimmingControlView.$leftTrimValue
//            .map(Double.init)
//            .sink { [weak self] position in
//                guard let self = self else { return }
//                self.store.send(event: .trim(.left, position))
//            }
//            .store(in: &cancellables)
//
//        trimmingControlView.$rightTrimValue
//            .map(Double.init)
//            .sink { [weak self] position in
//                guard let self = self else { return }
//                self.store.send(event: .trim(.right, position))
//            }
//            .store(in: &cancellables)
//
//        trimmingControlView.$seekerValue
//            .sink { [weak self] seekerPosition in
//                guard let self = self else { return }
//                guard self.trimmingControlView.isSeeking else { return }
//
//                let progress = Double(seekerPosition)
//                self.store.send(event: .seek(progress))
//            }
//            .store(in: &cancellables)
//
//        trimmingControlView.$isSeeking
//            .sink { [weak self] isSeeking in
//                guard let self = self else { return }
//
//                if !isSeeking {
//                    self.store.send(event: .stopSeeking)
//                }
//            }
//            .store(in: &cancellables)
//
//        trimmingControlView.$isTrimming
//            .sink { [weak self] isTrimming in
//                guard let self = self else { return }
//
//                if !isTrimming && self.store.state.isTrimming {
//                    self.store.send(event: .stopTrimming)
//                }
//            }
//            .store(in: &cancellables)
    }

    func updateVideoTimeline(with images: [CGImage], assetAspectRatio: CGFloat) {
        guard !trimmingControlView.isConfigured else { return }
        guard !images.isEmpty else { return }

        trimmingControlView.configure(with: images, assetAspectRatio: assetAspectRatio)
    }

    func updateSeekerPosition(progress: Double) {
        trimmingControlView.setSeekerValue(progress)
    }
}

// MARK: UI

fileprivate extension TrimVideoControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        view.backgroundColor = .white

        view.addSubview(trimmingControlView)
    }

    func setupConstraints() {
        trimmingControlView.autoSetDimension(.height, toSize: 60.0)
        trimmingControlView.autoPinEdge(toSuperviewEdge: .left, withInset: 28.0)
        trimmingControlView.autoPinEdge(toSuperviewEdge: .right, withInset: 28.0)
        trimmingControlView.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    func makeTrimmingControlView() -> TrimmingControlView {
        let view = TrimmingControlView()
        return view
    }
}
