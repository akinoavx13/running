//
//  HealthKitService.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

import HealthKit

protocol HealthKitServiceProtocol: AnyObject { }

final class HealthKitService: HealthKitServiceProtocol {
    
    // MARK: - Properties
    
    let healthStore: HKHealthStore

    // MARK: - Lifecycle
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.healthStore = healthStore
        
        Task {
            await requestPermission()
            let workouts = await fetchActivities(with: .running)
            
            for workout in workouts {
                dd(workout.startDate)
            }
        }
    }
    
    // MARK: - Methods
    
    func requestPermission() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let read: Set = [
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKSeriesType.workoutType()
        ]
        
        try? await healthStore.requestAuthorization(toShare: [], read: read)
    }
    
    func fetchActivities(with type: HKWorkoutActivityType) async -> [HKWorkout] {
        let samples: [HKSample] = await withCheckedContinuation { continuation in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(),
                                              predicate: HKQuery.predicateForWorkouts(with: type),
                                              limit: HKObjectQueryNoLimit,
                                              sortDescriptors: [.init(keyPath: \HKSample.startDate,
                                                                      ascending: false)],
                                              resultsHandler: { _, samples, error in
                guard error == nil,
                      let samples = samples
                else { return continuation.resume(returning: []) }
                
                return continuation.resume(returning: samples)
            }))
        }
         
        guard let workouts = samples as? [HKWorkout] else { return [] }
        
        return workouts
    }
}
