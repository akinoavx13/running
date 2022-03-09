//
//  SettingsDIContainer.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

protocol SettingsDIContainerProtocol: AnyObject {
    
    // MARK: - Methods
    
    func makeSettingsFlowCoordinator(navigationController: UINavigationController) -> SettingsFlowCoordinatorProtocol
}

final class SettingsDIContainer: SettingsDIContainerProtocol {
    
    struct Dependencies { }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies

    // MARK: - Lifecycle

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    
    func makeSettingsFlowCoordinator(navigationController: UINavigationController) -> SettingsFlowCoordinatorProtocol {
        SettingsFlowCoordinator(navigationController: navigationController,
                                dependencies: self)
    }
}

// MARK: - SettingsFlowCoordinatorDependencies -

extension SettingsDIContainer: SettingsFlowCoordinatorDependencies {
    func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController {
        SettingsViewController.create(with: SettingsViewModel(actions: actions))
    }
}
