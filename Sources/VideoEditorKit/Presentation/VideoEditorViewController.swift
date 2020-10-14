//
//  VideoEditorViewController.swift
//  
//
//  Created by Titouan Van Belle on 11.09.20.
//

import AVFoundation
import Combine
import PureLayout
import UIKit
import VideoPlayer

public protocol VideoEditorViewControllerDelegate: class {
    func save(editedAsset: AVAsset)
}

public final class VideoEditorViewController: UIViewController {

    // MARK: Public Properties

    public weak var delegate: VideoEditorViewControllerDelegate?

    // MARK: Private Properties

    private lazy var videoPlayerController: VideoPlayerController = makeVideoPlayerController()
    private lazy var videoEditorControlsViewController: VideoEditorControlsViewController = makeVideoEditorControlsViewController()

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

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }
}

// MARK: Public

public extension VideoEditorViewController {
    func load(asset: AVAsset) {
        store.send(event: .load(asset))
        if let editedItem = store.state.editedItem {
            videoPlayerController.load(item: editedItem)
        }
    }
}

// MARK: Bindings

fileprivate extension VideoEditorViewController {
    func setupBindings() {
        store.$state.sink { [weak self] state in
            guard let self = self else { return }

            switch state.status {

            case .idle:

                if state.shouldSeekBackToBeginning {
                    self.videoPlayerController.seek(toFraction: state.leftHandTrimMarkerPosition)
                    self.store.send(event: .reset)
                }

            case .seeking:
                self.videoPlayerController.pause()
                self.videoPlayerController.seek(toFraction: state.manualSeekPosition)

            case .trimming(let side):
                let position = state.trimMarkerPosition(for: side)
                self.videoPlayerController.pause()
                self.videoPlayerController.seek(toFraction: position)

            case .assetEdited(let asset, let videoComposition):
                let item = AVPlayerItem(asset: asset)
                item.videoComposition = videoComposition
                self.videoPlayerController.load(item: item)
                self.store.send(event: .reset)
                
            default:
                return
            }
        }.store(in: &cancellables)

        videoPlayerController.$fractionCompleted.sink { [weak self] fractionCompleted in
            guard let self = self else { return }
            self.store.send(event: .videoProgress(fractionCompleted))
        }.store(in: &cancellables)
    }
}

// MARK: UI

fileprivate extension VideoEditorViewController {
    func setupUI() {
        addSaveButton()
        setupView()
        setupConstraints()
    }

    func addSaveButton() {
        let image = UIImage(named: "Check", in: .module, compatibleWith: nil)
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = buttonItem
    }

    func setupView() {
        view.backgroundColor = .background

        add(videoPlayerController)
        add(videoEditorControlsViewController)
    }

    func setupConstraints() {
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .top)
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .left)
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .right)
        videoPlayerController.view.autoMatch(.height, to: .height, of: view, withMultiplier: 0.5)

        videoEditorControlsViewController.view.autoPinEdge(toSuperviewEdge: .bottom)
        videoEditorControlsViewController.view.autoPinEdge(toSuperviewEdge: .left)
        videoEditorControlsViewController.view.autoPinEdge(toSuperviewEdge: .right)
        videoEditorControlsViewController.view.autoPinEdge(.top, to: .bottom, of: videoPlayerController.view)
    }

    func makeVideoPlayerController() -> VideoPlayerController {
        viewFactory.makeVideoPlayerController()
    }

    func makeVideoEditorControlsViewController() -> VideoEditorControlsViewController {
        viewFactory.makeVideoEditorControlsViewController()
    }
}

// MARK: Actions

fileprivate extension VideoEditorViewController {
    @objc func save() {
        guard let editedAsset = store.state.editedAsset else { return }
        delegate?.save(editedAsset: editedAsset)
    }
}
