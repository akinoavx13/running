//
//  AppDIContainer.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

final class AppDIContainer {

    // MARK: - Containers
    
    lazy var analyseDIContainer: AnalyseDIContainerProtocol = {
        let dependencies = AnalyseDIContainer.Dependencies()
        
        return AnalyseDIContainer(dependencies: dependencies)
    }()
}
