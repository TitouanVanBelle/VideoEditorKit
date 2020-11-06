//
//  VideoControlCell.swift
//  
//
//  Created by Titouan Van Belle on 27.10.20.
//

import Foundation
import UIKit

final class VideoControlCell: UICollectionViewCell {

    // MARK: Private Properties

    private lazy var stack: UIStackView = makeStackView()
    private lazy var title: UILabel = makeTitle()
    private lazy var imageView: UIImageView = makeImageView()

    private var viewModel: VideoControlCellViewModel!

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Bindings

extension VideoControlCell {
    func configure(with viewModel: VideoControlCellViewModel) {
        title.text = viewModel.name
        imageView.image = UIImage(named: viewModel.imageName, in: .module, compatibleWith: nil)

        self.viewModel = viewModel
    }
}

// MARK: UI

fileprivate extension VideoControlCell {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        addSubview(stack)
    }

    func setupConstraints() {
        imageView.autoSetDimension(.height, toSize: 20.0)
        imageView.autoSetDimension(.width, toSize: 20.0)

        stack.autoCenterInSuperview()
    }
    
    func makeTitle() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .medium)
        label.textColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return label
    }

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1)
        return view
    }

    func makeStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            title
        ])

        stack.spacing = 10.0
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }
}
