//
//  ViewController.swift
//  VideoEditorDemo
//
//  Created by Titouan Van Belle on 25.09.20.
//

import AVFoundation
import AVKit
import Combine
import PureLayout
import UIKit
import VideoEditor
import VideoEditorKit

final class ViewController: UIViewController {

    // MARK: Private Properties

    private lazy var asset: AVAsset = makeAsset()
    private lazy var originalVideoPlayer: AVPlayerViewController = makeOriginalVideoPlayer()
    private lazy var editButton: UIButton = makeEditButton()
    private lazy var editedVideoPlayer: AVPlayerViewController = makeEditedVideoPlayer()
    private lazy var videoEditorViewController: VideoEditorViewController = makeVideoEditorViewController()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: UI

fileprivate extension ViewController {

    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        add(originalVideoPlayer)
        view.addSubview(editButton)
        add(editedVideoPlayer)
    }

    func setupConstraints() {
        originalVideoPlayer.view.autoPinEdge(toSuperviewSafeArea: .top)
        originalVideoPlayer.view.autoPinEdge(toSuperviewEdge: .left)
        originalVideoPlayer.view.autoPinEdge(toSuperviewEdge: .right)
        originalVideoPlayer.view.autoMatch(.height, to: .height, of: editedVideoPlayer.view)

        editButton.autoPinEdge(.top, to: .bottom, of: originalVideoPlayer.view)
        editButton.autoPinEdge(toSuperviewEdge: .left)
        editButton.autoPinEdge(toSuperviewEdge: .right)
        editButton.autoSetDimension(.height, toSize: 60.0)
        editButton.autoPinEdge(.bottom, to: .top, of: editedVideoPlayer.view)

        editedVideoPlayer.view.autoPinEdge(toSuperviewSafeArea: .bottom)
        editedVideoPlayer.view.autoPinEdge(toSuperviewEdge: .left)
        editedVideoPlayer.view.autoPinEdge(toSuperviewEdge: .right)
    }

    func makeAsset() -> AVAsset {
        Bundle.main.url(forResource: "HongKong", withExtension: "mp4")
            .map(AVAsset.init)!
    }

    func makeOriginalVideoPlayer() -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let item = AVPlayerItem(asset: asset)
        controller.player = AVPlayer(playerItem: item)
        return controller
    }

    func makeEditedVideoPlayer() -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer()
        return controller
    }

    func makeEditButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Edit Video", for: .normal)
        button.addTarget(self, action: #selector(edit), for: .touchUpInside)
        return button
    }

    func makeVideoEditorViewController() -> VideoEditorViewController {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let outputUrl = documentsDirectory.appendingPathComponent("video.mov")

        try? FileManager.default.removeItem(atPath: outputUrl.path)

        let controller = VideoEditorViewController(asset: asset, outputUrl: outputUrl)

        controller.onEditCompleted
            .sink { [weak self] _ in
                let item = AVPlayerItem(url: outputUrl)
                self?.editedVideoPlayer.player?.replaceCurrentItem(with: item)
            }
            .store(in: &cancellables)

        return controller
    }
}

// MARK: Actions

fileprivate extension ViewController {
    @objc func edit() {
        let navigationController = UINavigationController(rootViewController: videoEditorViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()

        present(navigationController, animated: true)
    }
}


fileprivate extension UIViewController {
    func add(_ controller: UIViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
