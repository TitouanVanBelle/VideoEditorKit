//
//  ViewController.swift
//  VideoEditorDemo
//
//  Created by Titouan Van Belle on 25.09.20.
//

import AVFoundation
import Combine
import PureLayout
import UIKit
import VideoEditor

final class ViewController: UIViewController {

    // MARK: Private Properties

    private lazy var videoEditorViewController: VideoEditorViewController = makeVideoEditorViewController()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        let url = Bundle.main.url(forResource: "Skate", withExtension: "mp4")!
        let asset = AVAsset(url: url)
        videoEditorViewController.load(asset: asset)
    }
}

// MARK: UI

fileprivate extension ViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        add(videoEditorViewController)
    }

    func setupConstraints() {
        videoEditorViewController.view.autoPinEdgesToSuperviewEdges()
    }

    func makeVideoEditorViewController() -> VideoEditorViewController {
        let factory = VideoEditorViewFactory()
        return factory.makeVideoEditorViewController()
    }
}

fileprivate extension UIViewController {
    func add(_ controller: UIViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
