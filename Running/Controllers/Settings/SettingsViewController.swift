//
//  SettingsViewController.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var viewModel: SettingsViewModelProtocol!
    
    private var composition = SettingsViewModel.Composition()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    static func create(with viewModel: SettingsViewModelProtocol) -> SettingsViewController {
        guard let viewController = R.storyboard.settingsViewController().instantiateInitialViewController()
                as? SettingsViewController
        else { fatalError("Could not instantiate SettingsViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = R.string.localizable.settings()
        
        bind(to: viewModel)
        
        refresh()
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: SettingsViewModelProtocol) {
        viewModel.composition
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.composition = $0
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func refresh() {
        Task {
            await viewModel.refresh()
        }
    }
}

// MARK: - UICollectionViewDataSource -

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }
//
//        switch type {
//        case let .intensity(viewModel):
//            let cell: IntensityCell = collectionView.dequeueReusableCell(for: indexPath)
//            cell.bind(to: viewModel)
//
//            return cell
//        }
        
        UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
//
//        switch type {
//        case .intensity: return IntensityCell.size
//        }
        
        .zero
    }
}
