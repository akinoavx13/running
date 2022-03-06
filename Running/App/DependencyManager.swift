//
//  DependencyManager.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

final class DependencyManager {
    
    // MARK: - Properties
    
    static let shared = DependencyManager()
    
    let healthKitService: HealthKitServiceProtocol = HealthKitService()

    // MARK: - Lifecycle
    
    private init() { }
}
