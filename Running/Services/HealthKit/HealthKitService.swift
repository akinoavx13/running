//
//  HealthKitService.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import HealthKit

protocol HealthKitServiceProtocol: AnyObject {
    
    // MARK: - Methods
    
    func fetchWorkouts(activity: HKWorkoutActivityType,
                       start: Date?,
                       end: Date?) async -> [HKWorkout]
    func fetchWorkout(with uuid: UUID) async -> HKWorkout?
}

final class HealthKitService: HealthKitServiceProtocol {
    
    // MARK: - Properties
    
    let healthStore: HKHealthStore
    
    // MARK: - Lifecycle
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
        
        Task {
            await requestAuthorization()
        }
    }
    
    // MARK: - Methods
    
    func fetchWorkouts(activity: HKWorkoutActivityType,
                       start: Date?,
                       end: Date?) async -> [HKWorkout] {
        let dateDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let predicate: NSPredicate
        
        if let start = start,
           let end = end {
            predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: end,
                                                    options: [])
        } else {
            predicate = HKQuery.predicateForWorkouts(with: activity)
        }
        
        let samples: [HKSample] = await withCheckedContinuation { continuation in
            healthStore.execute(HKSampleQuery(sampleType: HKSeriesType.workoutType(),
                                              predicate: predicate,
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [dateDescriptor],
                                              resultsHandler: { _, samples, error in
                guard error == nil,
                      let samples = samples
                else { return continuation.resume(returning: []) }
                
                return continuation.resume(returning: samples)
            }))
        }
     
        guard let workouts = samples as? [HKWorkout] else { return [] }
        
        return workouts.filter { $0.workoutActivityType == activity }
    }
    
    func fetchWorkout(with uuid: UUID) async -> HKWorkout? {
        let predicate = HKQuery.predicateForObject(with: uuid)
        
        let samples: [HKSample] = await withCheckedContinuation { continuation in
            healthStore.execute(HKSampleQuery(sampleType: HKSeriesType.workoutType(),
                                              predicate: predicate,
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [],
                                              resultsHandler: { _, samples, error in
                guard error == nil,
                      let samples = samples
                else { return continuation.resume(returning: []) }
                
                return continuation.resume(returning: samples)
            }))
        }
     
        guard let workouts = samples as? [HKWorkout] else { return nil }
        
        return workouts.first
    }
    
    // MARK: - Private methods
    
    private func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
              let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        else { return }
        
        let read: Set = [
            heartRate,
            distanceWalkingRunning,
            stepCount,
            basalEnergyBurned,
            activeEnergyBurned,
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKSeriesType.workoutType()
        ]
        
        try? await healthStore.requestAuthorization(toShare: [], read: read)
    }
    
    private func fetchHearthRate(for workout: HKWorkout) async -> [HKQuantitySample] {
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else { return [] }
        
        let dateDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let predicate = HKQuery.predicateForObjects(from: workout)
        let samples: [HKSample] = await withCheckedContinuation { continuation in
            healthStore.execute(HKSampleQuery(sampleType: heartRate,
                                              predicate: predicate,
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [dateDescriptor],
                                              resultsHandler: { _, samples, error in
                guard error == nil,
                      let samples = samples
                else { return continuation.resume(returning: []) }
                
                return continuation.resume(returning: samples)
            }))
        }
        
        guard let heartRates = samples as? [HKQuantitySample] else { return [] }

        return heartRates
    }
}
