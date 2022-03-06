//
//  AnalyseViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

import Combine

final class AnalyseViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let healthKitService: HealthKitServiceProtocol
    
    // MARK: - Lifecycle
    
    init(healthKitService: HealthKitServiceProtocol = DependencyManager.shared.healthKitService) {
        self.healthKitService = healthKitService
    }
    
}
