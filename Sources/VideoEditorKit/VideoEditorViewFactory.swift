//
//  VideoEditorViewFactory.swift
//
//
//  Created by Titouan Van Belle on 11.09.20.
//

import VideoPlayer

protocol VideoEditorViewFactoryProtocol {
    func makeVideoPlayerController() -> VideoPlayerController
    func makeVideoControlListController(store: VideoEditorStore) -> VideoControlListController
    func makeCropVideoControlViewController() -> CropVideoControlViewController
    func makeSpeedVideoControlViewController() -> SpeedVideoControlViewController
    func makeTrimVideoControlViewController() -> TrimVideoControlViewController
}

final class VideoEditorViewFactory: VideoEditorViewFactoryProtocol {

    func makeVideoPlayerController() -> VideoPlayerController {
        var theme = VideoPlayerController.Theme()
        theme.backgroundStyle = .plain(.white)
        return VideoPlayerController(capabilities: .none, theme: theme)
    }

    func makeVideoControlListController(store: VideoEditorStore) -> VideoControlListController {
        VideoControlListController(store: store, viewFactory: self)
    }

    func makeCropVideoControlViewController() -> CropVideoControlViewController {
        CropVideoControlViewController()
    }

    func makeSpeedVideoControlViewController() -> SpeedVideoControlViewController {
        SpeedVideoControlViewController()
    }

    func makeTrimVideoControlViewController() -> TrimVideoControlViewController {
        TrimVideoControlViewController()
    }
}
