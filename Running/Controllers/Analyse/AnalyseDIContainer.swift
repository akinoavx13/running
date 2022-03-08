//
//  AnalyseDIContainer.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

protocol AnalyseDIContainerProtocol: AnyObject {
    
    // MARK: - Methods
    
    func makeAnalyseFlowCoordinator(navigationController: UINavigationController) -> AnalyseFlowCoordinatorProtocol
}

final class AnalyseDIContainer: AnalyseDIContainerProtocol {
    
    struct Dependencies { }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeAnalyseFlowCoordinator(navigationController: UINavigationController) -> AnalyseFlowCoordinatorProtocol {
        AnalyseFlowCoordinator(navigationController: navigationController,
                               dependencies: self)
    }
}

// MARK: - AnalyseFlowCoordinatorDependencies -

extension AnalyseDIContainer: AnalyseFlowCoordinatorDependencies {
    func makeAnalyseViewController(actions: AnalyseViewModelActions) -> AnalyseViewController {
        AnalyseViewController.create(with: AnalyseViewModel(actions: actions))
    }
}
