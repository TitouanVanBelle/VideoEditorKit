//
//  CroppingControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import UIKit

final class CroppingControlViewController: UIViewController {

    // MARK: Public Properties

    override var tabBarItem: UITabBarItem! {
        get {
            UITabBarItem(
                title: "Crop",
                image: UIImage(named: "Crop", in: .module, compatibleWith: nil),
                selectedImage: UIImage(named: "Crop-Selected", in: .module, compatibleWith: nil)
            )
        }
        set {}
    }

    // MARK: Private Properties

    private let store: VideoEditorStore

    // MARK: Init

    init(store: VideoEditorStore) {
        self.store = store
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

fileprivate extension CroppingControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
    }

    func setupView() {

    }

    func setupConstraints() {

    }
}

