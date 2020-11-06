//
//  ModalVideoControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 29.10.20.
//

import Combine
import PureLayout
import UIKit

final class VideoControlViewController: UIViewController {

    // MARK: Public Properties

    @Published var speed: Double = .zero

    @Published var onDismiss = PassthroughSubject<Void, Never>()

    // MARK: Private Properties

    private lazy var borderTop: UIView = makeBorderTop()
    private lazy var titleStack: UIStackView = makeTitleStackView()
    private lazy var titleImageView: UIImageView = makeTitleImageView()
    private lazy var titleLabel: UILabel = makeTitleLabel()
    private lazy var dismissButton: UIButton = makeDismissButton()

    private lazy var speedVideoControlViewController: SpeedVideoControlViewController = makeSpeedVideoControlViewController()
    private lazy var trimVideoControlViewController: TrimVideoControlViewController = makeTrimVideoControlViewController()
    private lazy var audioVideoControlViewController: SpeedVideoControlViewController = makeSpeedVideoControlViewController()
    private lazy var cropVideoControlViewController: CropVideoControlViewController = makeCropVideoControlViewController()

    private var currentVideoControlViewController: UIViewController?

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        super.init(nibName: nil, bundle: nil)

        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Bindings

fileprivate extension VideoControlViewController {
    func setupBindings() {
        speedVideoControlViewController.$speed
            .assign(to: \.speed, weakly: self)
            .store(in: &cancellables)
    }
}

extension VideoControlViewController {
    func configure(with viewModel: VideoControlViewModel) {
        titleLabel.text = viewModel.title
        titleImageView.image = UIImage(named: viewModel.titleImageName, in: .module, compatibleWith: nil)

        currentVideoControlViewController?.remove()

        let videoControlViewController = self.videoControlViewController(for: viewModel.videoControl)

        add(videoControlViewController)

        videoControlViewController.view.autoPinEdge(.top, to: .bottom, of: titleStack)
        videoControlViewController.view.autoPinEdge(toSuperviewEdge: .left)
        videoControlViewController.view.autoPinEdge(toSuperviewEdge: .right)
        videoControlViewController.view.autoPinEdge(.bottom, to: .top, of: dismissButton)

        self.currentVideoControlViewController = videoControlViewController
    }
}

// MARK: UI

fileprivate extension VideoControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        view.addSubview(borderTop)
        view.addSubview(titleStack)
        view.addSubview(dismissButton)

        view.backgroundColor = .white
    }

    func setupConstraints() {
        borderTop.autoPinEdge(toSuperviewEdge: .left)
        borderTop.autoPinEdge(toSuperviewEdge: .right)
        borderTop.autoPinEdge(toSuperviewEdge: .top)
        borderTop.autoSetDimension(.height, toSize: 1.0)

        titleImageView.autoSetDimension(.height, toSize: 20.0)
        titleImageView.autoSetDimension(.width, toSize: 20.0)

        titleStack.autoPinEdge(.top, to: .bottom, of: borderTop, withOffset: 20.0)
        titleStack.autoAlignAxis(toSuperviewAxis: .vertical)
        titleStack.autoSetDimension(.height, toSize: 20.0)

        dismissButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 10.0)
        dismissButton.autoPinEdge(toSuperviewEdge: .right, withInset: 30.0)
    }

    func makeBorderTop() -> UIView {
        let view = UIView()
        view.backgroundColor = .border
        return view
    }

    func videoControlViewController(for videoControl: VideoControl) -> UIViewController {
        switch videoControl {
        case .audio:
            return speedVideoControlViewController
        case .crop:
            return cropVideoControlViewController
        case .speed:
            return speedVideoControlViewController
        case .trim:
            return trimVideoControlViewController
        }
    }

    func makeSpeedVideoControlViewController() -> SpeedVideoControlViewController {
        SpeedVideoControlViewController()
    }

    func makeTrimVideoControlViewController() -> TrimVideoControlViewController {
        TrimVideoControlViewController()
    }

    func makeCropVideoControlViewController() -> CropVideoControlViewController {
        CropVideoControlViewController()
    }

    func makeAudioVideoControlViewController() -> SpeedVideoControlViewController {
        SpeedVideoControlViewController()
    }

    func makeTitleStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            titleImageView,
            titleLabel
        ])

        stack.spacing = 10.0
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }

    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .medium)
        label.textColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return label
    }

    func makeTitleImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return view
    }

    func makeDismissButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "Check", in: .module, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }
}

// MARK: Actions

fileprivate extension VideoControlViewController {
    @objc func cancel() {
        onDismiss.send()
    }
}

