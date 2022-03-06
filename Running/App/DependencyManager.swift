//
//  DependencyManager.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

import Injectable

final class DependencyManager {
    
    // MARK: - Properties
    
    private let healthKitService: HealthKitService
    
    // MARK: - Lifecycle
    
    init() {
        self.healthKitService = HealthKitService()
        registerDependencies()
    }
    
    // MARK: - Methods
    
    private func registerDependencies() {
        let resolver = Resolver.shared
        
        resolver.register(healthKitService)
    }
}
