//
//  AnalyseViewController.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class AnalyseViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(cellType: IntensityCell.self)
            collectionView.register(cellType: ResumeCell.self)
            collectionView.register(cellType: SuggestedIntensityCell.self)
            collectionView.register(supplementaryViewType: SectionHeaderReusableView.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }
    
    private var refreshControl = UIRefreshControl()

    // MARK: - Properties
    
    var viewModel: AnalyseViewModelProtocol!
    
    private var composition = AnalyseViewModel.Composition()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    static func create(with viewModel: AnalyseViewModelProtocol) -> AnalyseViewController {
        guard let viewController = R.storyboard.analyseViewController().instantiateInitialViewController()
                as? AnalyseViewController
        else { fatalError("Could not instantiate AnalyseViewController.") }
        
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
        title = R.string.localizable.analyse()
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueDidChange), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }
    
    private func bind(to viewModel: AnalyseViewModelProtocol) {
        viewModel.composition
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.composition = $0
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func refresh() {
        viewModel.refresh()
        refreshControl.endRefreshing()
    }
    
    @objc private func refreshControlValueDidChange() {
        refreshControl.beginRefreshing()
        refresh()
    }
}

// MARK: - UICollectionViewDataSource -

extension AnalyseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { composition.sections.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { composition.sections[section].count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return UICollectionViewCell() }
        
        switch type {
        case let .intensity(viewModel):
            let cell: IntensityCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            
            return cell
        case let .resume(viewModel):
            let cell: ResumeCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.bind(to: viewModel)
            
            return cell
        case let .suggestedIntensity(viewModel):
            let cell: SuggestedIntensityCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(to: viewModel)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch composition.sections[indexPath.section].type {
        case let .intensity(viewModel), let .resume(viewModel), let .suggestedIntensity(viewModel):
            let headerView: SectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
            headerView.bind(to: viewModel)
            
            return headerView
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension AnalyseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let type = composition.sections[indexPath.section].cellForIndex(indexPath.row) else { return .zero }
        
        switch type {
        case .intensity: return IntensityCell.size
        case .resume: return ResumeCell.size
        case .suggestedIntensity: return SuggestedIntensityCell.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch composition.sections[section].type {
        case .intensity, .resume, .suggestedIntensity: return SectionHeaderReusableView.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0,
                     left: 0,
                     bottom: 12,
                     right: 0)
    }
}

// MARK: - ResumeCellDelegate -

extension AnalyseViewController: ResumeCellDelegate {
    func resumeCell(_ sender: ResumeCell,
                    intensityContainerDidTap view: UIView) {
        viewModel.update(resumeType: .intensity)
    }
    
    func resumeCell(_ sender: ResumeCell,
                    distanceContainerDidTap view: UIView) {
        viewModel.update(resumeType: .distance)
    }
    
    func resumeCell(_ sender: ResumeCell,
                    durationContainerDidTap view: UIView) {
        viewModel.update(resumeType: .duration)
    }
}
