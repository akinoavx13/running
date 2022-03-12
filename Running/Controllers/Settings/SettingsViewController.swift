//
//  SettingsViewController.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

final class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(cellType: LatestWorkoutCell.self)
            collectionView.register(cellType: EraseDataCell.self)
            collectionView.register(supplementaryViewType: SectionHeaderReusableView.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }
    
    private var refreshControl = UIRefreshControl()
    
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
        
        configure()
        
        bind(to: viewModel)
        
        refresh()
    }
    
    // MARK: - Private methods
    
    private func configure() {
        title = R.string.localizable.settings()
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueDidChange), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }
    
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
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func importWorkout(uuid: UUID) {
        HUD.show(.progress)
        
        Task {
            let isSuccess = await viewModel.importWorkout(uuid: uuid)
            
            DispatchQueue.main.async {
                HUD.flash(isSuccess ? .success : .error, delay: Constants.defaultHUDDuration)
            }
        }
    }
    
    private func eraseAllData() {
        HUD.show(.progress)
        
        Task {
            await viewModel.eraseAllData()
            
            DispatchQueue.main.async { HUD.hide() }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshControlValueDidChange() {
        refreshControl.beginRefreshing()
        refresh()
    }
}

// MARK: - UICollectionViewDataSource -

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }

        switch type {
        case let .latestWorkout(viewModel):
            let cell: LatestWorkoutCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            cell.delegate = self
            
            return cell
        case .eraseData:
            let cell: EraseDataCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch composition.sections[indexPath.section].type {
        case let .latestWorkouts(viewModel):
            let headerView: SectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
            headerView.bind(to: viewModel)
            
            return headerView
        case .eraseData: return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }

        switch type {
        case .latestWorkout: return LatestWorkoutCell.size
        case .eraseData: return EraseDataCell.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch composition.sections[section].type {
        case .latestWorkouts: return SectionHeaderReusableView.size
        case .eraseData: return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        switch composition.sections[section].type {
        case .latestWorkouts: return UIEdgeInsets(top: 8,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 0)
        case .eraseData: return UIEdgeInsets(top: 16,
                                             left: 0,
                                             bottom: 0,
                                             right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch composition.sections[section].type {
        case .latestWorkouts: return 6
        case .eraseData: return 0
        }
    }
}

// MARK: - LatestWorkoutCellDelegate -

extension SettingsViewController: LatestWorkoutCellDelegate {
    func latestWorkoutCell(_ sender: LatestWorkoutCell,
                           importButtonDidTap button: AnimateButton,
                           uuid: UUID) {
        importWorkout(uuid: uuid)
    }
}

// MARK: - EraseDataCellDelegate -

extension SettingsViewController: EraseDataCellDelegate {
    func eraseDataCell(_ sender: EraseDataCell,
                       eraseButtonDidTap button: AnimateButton) {
        eraseAllData()
    }
}
