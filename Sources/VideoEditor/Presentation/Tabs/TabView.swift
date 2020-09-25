//
//  TabView.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import UIKit

final class TabView: UIView {

    // MARK: Private Properties

    private lazy var stack: UIStackView = makeStack()
    private lazy var titleLabel: UILabel = makeTitleLabel()
    private lazy var imageView: UIImageView = makeImageView()

    private let tabBarItem: UITabBarItem

    // MARK: Init

    init(tabBarItem: UITabBarItem) {
        self.tabBarItem = tabBarItem

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension TabView {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        addSubview(stack)
    }

    func setupConstraints() {
        imageView.autoMatch(.height, to: .height, of: self, withMultiplier: 0.25)
        imageView.autoMatch(.width, to: .width, of: self, withMultiplier: 0.25)

        stack.autoCenterInSuperview()
    }

    func makeStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel
        ])
        stack.axis = .vertical
        stack.spacing = 10.0
        stack.alignment = .center
        return stack
    }

    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = tabBarItem.title?.uppercased()
        label.font = .systemFont(ofSize: 11.0, weight: .medium)
        label.textColor = .primaryForeground
        return label
    }

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.tintColor = .white
        view.image = tabBarItem.image
        return view
    }
}
