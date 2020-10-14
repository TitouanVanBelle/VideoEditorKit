//
//  TabsViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import PureLayout
import UIKit

public final class TabsViewController: UIViewController {

    // MARK: Private Properties

    private lazy var tabsScrollView: UIScrollView = makeTabsScrollView()
    private lazy var tabsStackView: UIStackView = makeTabsStackView()
    private lazy var tabs: [TabView] = makeTabs()
    private lazy var tabViews: [UIView] = makeTabViews()

    private lazy var controllersScrollView: UIScrollView = makeControllersScrollView()

    private let viewControllers: [UIViewController]

    // MARK: Init

    public init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

fileprivate extension TabsViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {
        view.addSubview(tabsScrollView)
        view.addSubview(controllersScrollView)

        tabsScrollView.addSubview(tabsStackView)
        viewControllers.forEach {
            self.addChild($0)
            $0.didMove(toParent: self)
            controllersScrollView.addSubview($0.view)
        }
    }

    func setupConstraints() {
        let height: CGFloat = 80.0
        tabViews.forEach {
            if $0 is TabView {
                $0.autoSetDimension(.height, toSize: height)
                $0.autoSetDimension(.width, toSize: height)
            }
        }

        tabsStackView.autoMatch(.width, to: .width, of: tabsScrollView, withMultiplier: 1.0, relation: .greaterThanOrEqual)

        tabsScrollView.autoPinEdge(toSuperviewEdge: .left)
        tabsScrollView.autoPinEdge(toSuperviewEdge: .bottom)
        tabsScrollView.autoPinEdge(toSuperviewEdge: .right)
        tabsScrollView.autoSetDimension(.height, toSize: height)

        controllersScrollView.autoPinEdge(toSuperviewEdge: .left)
        controllersScrollView.autoPinEdge(toSuperviewEdge: .top)
        controllersScrollView.autoPinEdge(toSuperviewEdge: .right)
        controllersScrollView.autoPinEdge(.bottom, to: .top, of: tabsScrollView)

        viewControllers.enumerated().forEach {
            $0.element.view.autoPinEdge(.top, to: .top, of: controllersScrollView)
            $0.element.view.autoPinEdge(.bottom, to: .bottom, of: controllersScrollView)
            $0.element.view.autoMatch(.width, to: .width, of: controllersScrollView)
            $0.element.view.autoMatch(.height, to: .height, of: controllersScrollView)

            if $0.offset == 0 {
                $0.element.view.autoPinEdge(.left, to: .left, of: controllersScrollView)
            } else {
                $0.element.view.autoPinEdge(.left, to: .right, of: viewControllers[$0.offset - 1].view)
            }

            if $0.offset == viewControllers.count - 1 {
                $0.element.view.autoPinEdge(.right, to: .right, of: controllersScrollView)
            }
        }
    }

    func makeTabsScrollView() -> UIScrollView {
        let view = UIScrollView()
        return view
    }

    func makeTabsStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: tabViews)
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }

    func makeTabs() -> [TabView] {
        viewControllers.map(\.tabBarItem)
            .map(TabView.init)
    }

    func makeTabViews() -> [UIView] {
        var views: [UIView] = tabs

        views.forEach {
            $0.addGestureRecognizer(makeTapGestureRecognizer())
        }

        views.append(UIView(frame: .zero))
        views.insert(UIView(frame: .zero), at: 0)
        return views
    }

    func makeControllersScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.isScrollEnabled = false
        return view
    }
}

fileprivate extension TabsViewController {
    func scrollTo(page: Int) {
        let point = CGPoint(
            x: controllersScrollView.frame.size.width * CGFloat(page),
            y: controllersScrollView.contentOffset.y
        )
        controllersScrollView.setContentOffset(point, animated: false)
    }
}

fileprivate extension TabsViewController {
    @objc func tabTapped(_ recognizer: UITapGestureRecognizer) {
        guard let tabView = recognizer.view as? TabView,
            let page = tabs.firstIndex(of: tabView) else { return }

        scrollTo(page: page)
    }
}
