//
//  VideoEditorViewFactory.swift
//
//
//  Created by Titouan Van Belle on 11.09.20.
//

import AVFoundation // TODO: Remove
import VideoPlayer

public protocol VideoEditorViewFactoryProtocol {
    func makeVideoEditorViewController() -> VideoEditorViewController
}

protocol InternalVideoEditorViewFactoryProtocol {
    func makeVideoPlayerController() -> VideoPlayerController
    func makeVideoEditorControlsViewController() -> VideoEditorControlsViewController
    func makeCroppingControlViewController() -> CroppingControlViewController
    func makeVideoSpeedControlViewController() -> VideoSpeedControlViewController
    func makeTrimmingControlViewController() -> TrimmingControlViewController
}

public final class VideoEditorViewFactory: VideoEditorViewFactoryProtocol, InternalVideoEditorViewFactoryProtocol {

    // MARK: Private Properties

    private var store: VideoEditorStore!
    private let videoPlayerViewFactory = VideoPlayerViewFactory()

    // MARK: Init

    public init() {}

    public func makeVideoEditorViewController() -> VideoEditorViewController {
        let editor = VideoEditor()
        let generator = VideoTimelineGenerator()
        let store = VideoEditorStore(
            editor: editor,
            generator: generator
        )

        self.store = store
        return VideoEditorViewController(store: store, viewFactory: self)
    }

    func makeVideoPlayerController() -> VideoPlayerController {
        videoPlayerViewFactory.makeVideoPlayerController()
    }

    func makeVideoEditorControlsViewController() ->VideoEditorControlsViewController {
        VideoEditorControlsViewController(store: store, viewFactory: self)
    }

    func makeCroppingControlViewController() -> CroppingControlViewController {
        CroppingControlViewController(store: store)
    }

    func makeVideoSpeedControlViewController() -> VideoSpeedControlViewController {
        VideoSpeedControlViewController(store: store)
    }

    func makeTrimmingControlViewController() -> TrimmingControlViewController {
        TrimmingControlViewController(store: store)
    }
}
