//
//  AnalyseFlowCoordinator.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

protocol AnalyseFlowCoordinatorDependencies: AnyObject {
    
    // MARK: - Methods
    
    func makeAnalyseViewController(actions: AnalyseViewModelActions) -> AnalyseViewController
    
}

protocol AnalyseFlowCoordinatorProtocol: AnyObject {
    func start()
}

final class AnalyseFlowCoordinator: AnalyseFlowCoordinatorProtocol {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    
    private let dependencies: AnalyseFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: AnalyseFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = AnalyseViewModelActions()
        
        DispatchQueue.main.async {
            let viewController = self.dependencies.makeAnalyseViewController(actions: actions)
            
            self.navigationController?.setViewControllers([viewController],
                                                          animated: false)
        }
    }
}
