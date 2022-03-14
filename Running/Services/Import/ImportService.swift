//
//  ImportService.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

import Foundation
import HealthKit

protocol ImportServiceProtocol: AnyObject {
    func availableForImport(activity: HKWorkoutActivityType,
                            start: Date,
                            end: Date) async -> [HKWorkout]
    func importWorkout(uuid: UUID) async
    func isImported(uuid: UUID) -> Bool
}

final class ImportService: ImportServiceProtocol {
    
    // MARK: - Properties
    
    private let healthKitService: HealthKitServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    // MARK: - Lifecycle
    
    init(healthKitService: HealthKitServiceProtocol,
         databaseService: DatabaseServiceProtocol) {
        self.healthKitService = healthKitService
        self.databaseService = databaseService
    }
    
    // MARK: - Methods
    
    func availableForImport(activity: HKWorkoutActivityType,
                            start: Date,
                            end: Date) async -> [HKWorkout] {
        let workouts = await healthKitService.fetchWorkouts(activity: activity,
                                                            start: start,
                                                            end: end)
        
        return workouts.filter { $0.metadata?[HKMetadataKeyAverageMETs] != nil }
    }
    
    func importWorkout(uuid: UUID) async {
        guard let workout = await healthKitService.fetchWorkout(with: uuid),
              !isImported(uuid: uuid)
        else { return }
        
        let heartRate = await healthKitService.fetchQuantitySample(for: workout,
                                                                      quantityType: .heartRate)
        let distanceWalkingRunning = await healthKitService.fetchQuantitySample(for: workout,
                                                                                   quantityType: .distanceWalkingRunning)
        let stepCount = await healthKitService.fetchQuantitySample(for: workout,
                                                                      quantityType: .stepCount)
        let basalEnergyBurned = await healthKitService.fetchQuantitySample(for: workout,
                                                                              quantityType: .basalEnergyBurned)
        let activeEnergyBurned = await healthKitService.fetchQuantitySample(for: workout,
                                                                               quantityType: .activeEnergyBurned)
        
        databaseService.save(workout: workout,
                             hearthRate: heartRate,
                             distanceWalkingRunning: distanceWalkingRunning,
                             stepCount: stepCount,
                             basalEnergyBurned: basalEnergyBurned,
                             activeEnergyBurned: activeEnergyBurned)
    }
    
    func isImported(uuid: UUID) -> Bool {
        databaseService.fetchWorkout(with: uuid) != nil
    }
}
