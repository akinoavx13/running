//
//  AppDIContainer.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

final class AppDIContainer {

    // MARK: - Services

    private lazy var healthKitService: HealthKitServiceProtocol = {
        HealthKitService()
    }()
    
    // MARK: - Containers
    
    lazy var analyseDIContainer: AnalyseDIContainerProtocol = {
        let dependencies = AnalyseDIContainer.Dependencies(healthKitService: healthKitService)
        
        return AnalyseDIContainer(dependencies: dependencies)
    }()
    
    lazy var settingsDIContainer: SettingsDIContainerProtocol = {
        let dependencies = SettingsDIContainer.Dependencies()
        
        return SettingsDIContainer(dependencies: dependencies)
    }()
}
