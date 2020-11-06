//
//  CropVideoControlViewController.swift
//  
//
//  Created by Titouan Van Belle on 14.09.20.
//

import UIKit
import VideoEditor

final class CropVideoControlViewController: UIViewController {

    // MARK: Inner Types

    enum Section: Hashable {
        case main
    }

    typealias Datasource = UICollectionViewDiffableDataSource<Section, CroppingPresetCellViewModel>

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

    private lazy var collectionView: UICollectionView = makeCollectionView()

    private var datasource: Datasource!

    // MARK: Init

    init() {        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        loadPresets()
    }
}

// MARK: Data

fileprivate extension CropVideoControlViewController {
    func loadPresets() {
        let viewModels = CroppingPreset.allCases.map(CroppingPresetCellViewModel.init)
        var snapshot = NSDiffableDataSourceSnapshot<Section, CroppingPresetCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels, toSection: .main)
        datasource.apply(snapshot, animatingDifferences: true)
    }
}

fileprivate extension CropVideoControlViewController {
    func setupUI() {
        setupView()
        setupConstraints()
        setupCollectionView()
    }

    func setupView() {
        view.backgroundColor = .white

        view.addSubview(collectionView)
    }

    func setupConstraints() {
        collectionView.autoSetDimension(.height, toSize: 100.0)
        collectionView.autoPinEdge(toSuperviewEdge: .left)
        collectionView.autoPinEdge(toSuperviewEdge: .right)
        collectionView.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    func setupCollectionView() {
        let identifier = "CroppingPresetView"
        collectionView.delegate = self
        collectionView.register(CroppingPresetCell.self, forCellWithReuseIdentifier: identifier)
        datasource = Datasource(collectionView: collectionView) { collectionView, indexPath, preset in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: identifier,
                for: indexPath
            ) as! CroppingPresetCell

            cell.configure(with: preset)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()

            return cell
        }
    }

    func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        return view
    }
}


extension CropVideoControlViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 90, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CroppingPresetCell {
            cell.isSelected.toggle()
        }

        if let viewModel = datasource.itemIdentifier(for: indexPath) {
//            store.send(event: .updateCroppingPreset(viewModel.croppingPreset))
        }
    }
}
