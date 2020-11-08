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
import VideoEditorKit

final class ViewController: UIViewController {

    // MARK: Private Properties

    private lazy var videoEditorViewController: VideoEditorViewController = makeVideoEditorViewController()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let navigationController = UINavigationController(rootViewController: videoEditorViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.shadowImage = UIImage()

        present(navigationController, animated: true)
    }
}

// MARK: UI

fileprivate extension ViewController {
    func makeVideoEditorViewController() -> VideoEditorViewController {
        let url = Bundle.main.url(forResource: "HongKong", withExtension: "mp4")!
        let asset = AVAsset(url: url)

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let outputUrl = documentsDirectory.appendingPathComponent("video.mov")

        try? FileManager.default.removeItem(atPath: outputUrl.path)

        print(outputUrl)

        return VideoEditorViewController(asset: asset, outputUrl: outputUrl)
    }
}

fileprivate extension UIViewController {
    func add(_ controller: UIViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
