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
import VideoEditor
import VideoPlayer

public final class VideoEditorViewController: UIViewController {

    // MARK: Published Properties

    public var onEditCompleted = PassthroughSubject<(AVPlayerItem, VideoEdit), Never>()

    // MARK: Private Properties

    private lazy var saveButtonItem: UIBarButtonItem = makeSaveButtonItem()
    private lazy var dismissButtonItem: UIBarButtonItem = makeDismissButtonItem()

    private lazy var videoPlayerController: VideoPlayerController = makeVideoPlayerController()
    private lazy var playButton: PlayPauseButton = makePlayButton()
    private lazy var durationLabel: UILabel = makeDurationLabel()
    private lazy var fullscreenButton: UIButton = makeFullscreenButton()
    private lazy var controlsStack: UIStackView = makeControlsStack()
    private lazy var videoTimelineViewController: VideoTimelineViewController = makeVideoTimelineViewController()
    private lazy var videoControlListController: VideoControlListController = makeVideoControlListControllers()
    private lazy var videoControlViewController: VideoControlViewController = makeVideoControlViewController()

    private var videoControlHeightConstraint: NSLayoutConstraint!

    private var cancellables = Set<AnyCancellable>()

    private let store: VideoEditorStore
    private let viewFactory: VideoEditorViewFactoryProtocol

    // MARK: Init

    public init(asset: AVAsset, videoEdit: VideoEdit? = nil) {
        self.store = VideoEditorStore(asset: asset, videoEdit: videoEdit)
        self.viewFactory = VideoEditorViewFactory()

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

        #if targetEnvironment(simulator)
        print("Warning: Cropping only works on real device and has been disabled on simulator")
        #endif
    }
}

// MARK: Bindings

fileprivate extension VideoEditorViewController {
    func setupBindings() {
        store.$playheadProgress
            .sink { [weak self] playheadProgress in
                guard let self = self else { return }
                self.updateDurationLabel()
            }
            .store(in: &cancellables)
        
        store.$editedPlayerItem
            .sink { [weak self] item in
                guard let self = self else { return }
                self.videoPlayerController.load(item: item, autoPlay: false)
                self.videoTimelineViewController.generateTimeline(for: item.asset)
            }
            .store(in: &cancellables)

        videoPlayerController.$currentTime
            .assign(to: \.playheadProgress, weakly: store)
            .store(in: &cancellables)

        videoPlayerController.$isPlaying
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                self.playButton.isPaused = !isPlaying
            }
            .store(in: &cancellables)

        store.$isSeeking
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.videoPlayerController.pause()
            }.store(in: &cancellables)

        store.$currentSeekingValue
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.store.isSeeking
            }
            .sink { [weak self] seekingValue in
                guard let self = self else { return }
                self.videoPlayerController.seek(toFraction: seekingValue)
            }
            .store(in: &cancellables)

        videoControlListController.didSelectVideoControl
            .sink { [weak self] videoControl in
                guard let self = self else { return }
                self.presentVideoControlController(for: videoControl)
            }
            .store(in: &cancellables)

        videoControlViewController.$speed
            .dropFirst(1)
            .assign(to: \.speed, weakly: store)
            .store(in: &cancellables)

        videoControlViewController.$trimPositions
            .dropFirst(1)
            .assign(to: \.trimPositions, weakly: store)
            .store(in: &cancellables)

        videoControlViewController.$croppingPreset
            .dropFirst(1)
            .assign(to: \.croppingPreset, weakly: store)
            .store(in: &cancellables)

        videoControlViewController.onDismiss
            .sink { [unowned self] _ in
                self.animateVideoControlViewControllerOut()
            }
            .store(in: &cancellables)
    }
}

// MARK: UI

fileprivate extension VideoEditorViewController {
    func setupUI() {
        setupNavigationItems()
        setupView()
        setupConstraints()
    }

    func setupNavigationItems() {
        let lNegativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        lNegativeSeperator.width = 10

        let rNegativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rNegativeSeperator.width = 10

        navigationItem.rightBarButtonItems = [rNegativeSeperator, saveButtonItem]
        navigationItem.leftBarButtonItems = [lNegativeSeperator, dismissButtonItem]
    }

    func setupView() {
        view.backgroundColor = .background

        add(videoPlayerController)
        view.addSubview(controlsStack)
        add(videoTimelineViewController)
        add(videoControlListController)
    }

    func setupConstraints() {
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .top)
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .left)
        videoPlayerController.view.autoPinEdge(toSuperviewEdge: .right)
        videoPlayerController.view.autoPinEdge(.bottom, to: .top, of: controlsStack)

        playButton.autoSetDimension(.height, toSize: 44.0)
        playButton.autoSetDimension(.width, toSize: 44.0)
        fullscreenButton.autoSetDimension(.height, toSize: 44.0)
        fullscreenButton.autoSetDimension(.width, toSize: 44.0)

        controlsStack.autoSetDimension(.height, toSize: 44.0)
        controlsStack.autoPinEdge(toSuperviewEdge: .left)
        controlsStack.autoPinEdge(toSuperviewEdge: .right)
        controlsStack.autoPinEdge(.bottom, to: .top, of: videoTimelineViewController.view)

        videoTimelineViewController.view.autoSetDimension(.height, toSize: 220.0)
        videoTimelineViewController.view.autoPinEdge(toSuperviewEdge: .left)
        videoTimelineViewController.view.autoPinEdge(toSuperviewEdge: .right)
        videoTimelineViewController.view.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 60.0)

        videoControlListController.view.autoPinEdge(toSuperviewSafeArea: .bottom)
        videoControlListController.view.autoPinEdge(toSuperviewEdge: .left)
        videoControlListController.view.autoPinEdge(toSuperviewEdge: .right)
        videoControlListController.view.autoSetDimension(.height, toSize: 60.0)
    }

    func updateDurationLabel() {
        let currentTimeInSeconds = videoPlayerController.currentTime.seconds
        let formattedCurrentTime = currentTimeInSeconds >= 3600 ?
            DateComponentsFormatter.longDurationFormatter.string(from: currentTimeInSeconds) ?? "" :
            DateComponentsFormatter.shortDurationFormatter.string(from: currentTimeInSeconds) ?? ""

        var durationInSeconds = videoPlayerController.player.currentItem?.duration.seconds ?? 0.0
        durationInSeconds = durationInSeconds.isNaN ? 0.0 : durationInSeconds
        let formattedDuration = durationInSeconds >= 3600 ?
            DateComponentsFormatter.longDurationFormatter.string(from: durationInSeconds) ?? "" :
            DateComponentsFormatter.shortDurationFormatter.string(from: durationInSeconds) ?? ""

        durationLabel.text = "\(formattedCurrentTime) | \(formattedDuration)"
    }

    func makeSaveButtonItem() -> UIBarButtonItem {
        let image = UIImage(named: "Check", in: .module, compatibleWith: nil)
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(save))
        buttonItem.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return buttonItem
    }

    func makeDismissButtonItem() -> UIBarButtonItem {
        let imageName = isModal ? "Close" : "Back"
        let image = UIImage(named: imageName, in: .module, compatibleWith: nil)
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(cancel))
        buttonItem.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return buttonItem
    }

    func makeVideoPlayerController() -> VideoPlayerController {
        let controller = viewFactory.makeVideoPlayerController()
        return controller
    }

    func makePlayButton() -> PlayPauseButton {
        let button = PlayPauseButton()
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        button.imageEdgeInsets = .init(top: 13, left: 15, bottom: 13, right: 15)
        return button
    }

    func makeDurationLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "0:00 | 0:00"
        label.font = .systemFont(ofSize: 13.0)
        label.textColor = .foreground
        return label
    }

    func makeFullscreenButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "EnterFullscreen", in: .module, compatibleWith: nil)
        button.addTarget(self, action: #selector(fullscreenButtonTapped), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        button.imageEdgeInsets = .init(top: 14, left: 13, bottom: 14, right: 13)
        return button
    }

    func makeControlsStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            playButton,
            durationLabel,
            fullscreenButton
        ])

        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)

        stack.axis = .horizontal
        stack.distribution = .equalSpacing

        return stack
    }

    func makeVideoTimelineViewController() -> VideoTimelineViewController {
        viewFactory.makeVideoTimelineViewController(store: store)
    }

    func makeVideoControlListControllers() -> VideoControlListController {
        viewFactory.makeVideoControlListController(store: store)
    }

    func makeVideoControlViewController() -> VideoControlViewController {
        viewFactory.makeVideoControlViewController(
            asset: store.originalAsset,
            speed: store.speed,
            trimPositions: store.trimPositions
        )
    }

    func presentVideoControlController(for videoControl: VideoControl) {
        if videoControlViewController.view.superview == nil {
            let height: CGFloat = 210.0
            let offset = -(height + view.safeAreaInsets.bottom)

            add(videoControlViewController)

            videoControlViewController.view.autoPinEdge(toSuperviewEdge: .right)
            videoControlViewController.view.autoPinEdge(toSuperviewEdge: .left)
            videoControlViewController.view.autoSetDimension(.height, toSize: height)
            videoControlViewController.view.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: offset)

            self.view.layoutIfNeeded()
        }

        let viewModel = VideoControlViewModel(videoControl: videoControl)
        videoControlViewController.configure(with: viewModel)

        animateVideoControlViewControllerIn()
    }

    func animateVideoControlViewControllerIn() {
        let y = -(videoControlViewController.view.bounds.height + view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.videoControlViewController.view.transform = CGAffineTransform(translationX: 0, y: y)
        })
    }

    func animateVideoControlViewControllerOut() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.videoControlViewController.view.transform = .identity
        })
    }
}

// MARK: Actions

fileprivate extension VideoEditorViewController {
    @objc func fullscreenButtonTapped() {
        videoPlayerController.enterFullscreen()
    }

    @objc func playButtonTapped() {
        if videoPlayerController.isPlaying {
            videoPlayerController.pause()
        } else {
            videoPlayerController.play()
        }
    }

    @objc func save() {
        let item = AVPlayerItem(asset: store.editedPlayerItem.asset)

        #if !targetEnvironment(simulator)
        item.videoComposition = store.editedPlayerItem.videoComposition
        #endif

        onEditCompleted.send((item, store.videoEdit))
        dismiss(animated: true)
    }

    @objc func cancel() {
        let alert = UIAlertController(title: "Are you sure?", message: "The video edit will be lost when dismiss the screen.", preferredStyle: .alert)

        let dismissAction = UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { _ in
                if self.isModal {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        )
        alert.addAction(dismissAction)

        let cancelAction = UIAlertAction(
            title: "No",
            style: .cancel,
            handler: { _ in }
        )
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
