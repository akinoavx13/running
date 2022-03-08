//
//  AppDelegate.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private let appDIContainer = AppDIContainer()
    private var appFlowCoordinator: AppFlowCoordinator?
    
    // MARK: - Lifecycle
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = UITabBarController()

        window?.rootViewController = tabBarController
        appFlowCoordinator = AppFlowCoordinator(tabBarController: tabBarController,
                                                appDIContainer: appDIContainer)
        
        appFlowCoordinator?.start()
        window?.makeKeyAndVisible()
                
        return true
    }
}
