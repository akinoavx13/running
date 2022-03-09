//
//  SettingsFlowCoordinator.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

protocol SettingsFlowCoordinatorDependencies: AnyObject {
    
    // MARK: - Methods
    
    func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController
    
}

protocol SettingsFlowCoordinatorProtocol: AnyObject {
    func start()
}

final class SettingsFlowCoordinator: SettingsFlowCoordinatorProtocol {
    
    // MARK: - Properties
    
    private weak var navigationController: UINavigationController?
    
    private let dependencies: SettingsFlowCoordinatorDependencies
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController,
         dependencies: SettingsFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func start() {
        let actions = SettingsViewModelActions()
        
        DispatchQueue.main.async {
            let viewController = self.dependencies.makeSettingsViewController(actions: actions)
            
            self.navigationController?.setViewControllers([viewController],
                                                          animated: false)
        }
    }
}
