//
//  AppFlowCoordinator.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

final class AppFlowCoordinator {

    private enum Tab: CaseIterable {
        case analyse
        
        var tabBarItem: UITabBarItem {
            switch self {
            case .analyse:
                return UITabBarItem(title: R.string.localizable.analyse(),
                                    image: R.image.icons.chartMixed(),
                                    selectedImage: nil)
            }
        }
    }
    
    // MARK: - Properties
    
    private let tabBarController: UITabBarController
    private let appDIContainer: AppDIContainer
    private let application: UIApplication
    
    // MARK: - Lifecycle
    
    init(tabBarController: UITabBarController,
         appDIContainer: AppDIContainer,
         application: UIApplication = UIApplication.shared) {
        self.tabBarController = tabBarController
        self.appDIContainer = appDIContainer
        self.application = application
    }

    // MARK: - Methods
    
    func start() {
        Tab.allCases.forEach(add(tab:))
    }
    
    // MARK: - Private methods
    
    private func add(tab: Tab) {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = tab.tabBarItem
        
        var viewControllers = tabBarController.viewControllers ?? []
        viewControllers += [navigationController]
        tabBarController.setViewControllers(viewControllers, animated: true)
        
        switch tab {
        case .analyse:
            navigationController.navigationBar.prefersLargeTitles = true
            
            appDIContainer
                .analyseDIContainer
                .makeAnalyseFlowCoordinator(navigationController: navigationController)
                .start()
        }
    }
}
