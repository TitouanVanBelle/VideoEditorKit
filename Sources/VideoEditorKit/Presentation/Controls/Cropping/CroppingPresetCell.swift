//
//  CroppingPresetView.swift
//  
//
//  Created by Titouan Van Belle on 09.10.20.
//

import UIKit
import UIKit

final class CroppingPresetCell: UICollectionViewCell {

    // MARK: Public Properties

    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    // MARK: Private Properties

    private lazy var stack: UIStackView = makeStackView()
    private lazy var title: UILabel = makeTitle()
    private lazy var imageView: UIImageView = makeImageView()

    private var viewModel: CroppingPresetCellViewModel!

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

extension CroppingPresetCell {
    func configure(with viewModel: CroppingPresetCellViewModel) {
        title.text = viewModel.name
        imageView.image = UIImage(named: viewModel.imageName, in: .module, compatibleWith: nil)

        self.viewModel = viewModel
    }
}

// MARK: UI

fileprivate extension CroppingPresetCell {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        addSubview(stack)
    }

    func setupConstraints() {
        imageView.autoSetDimension(.height, toSize: 48.0)
        imageView.autoSetDimension(.width, toSize: 48.0)

        stack.autoCenterInSuperview()
    }

    func updateUI() {
        title.textColor = isSelected ? .white : .gray
        let imageName = isSelected ? viewModel.selectedImageName : viewModel.imageName
        imageView.image = UIImage(named: imageName, in: .module, compatibleWith: nil)
    }

    func makeTitle() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0, weight: .medium)
        label.textColor = .gray
        return label
    }

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
