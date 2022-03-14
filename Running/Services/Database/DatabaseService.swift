//
//  DatabaseService.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

import CoreData
import HealthKit

protocol DatabaseServiceProtocol: AnyObject {
    
    // MARK: - Methods
    
    func fetchWorkout(with uuid: UUID) -> CDWorkout?
    func fetchWorkouts(start: Date?,
                       end: Date?) -> [CDWorkout]
    func fetchUser() -> CDUser?
    func save(workout: HKWorkout,
              hearthRate: [HKQuantitySample],
              distanceWalkingRunning: [HKQuantitySample],
              stepCount: [HKQuantitySample],
              basalEnergyBurned: [HKQuantitySample],
              activeEnergyBurned: [HKQuantitySample])
    func eraseAllData()
}

final class DatabaseService: DatabaseServiceProtocol {
    
    // MARK: - Properties
    
    private var persistentContainer: NSPersistentContainer!
    private var context: NSManagedObjectContext!
    
    // MARK: - Lifecycle
    
    init() {
        initDatabase()
        
        updateUserMaxHeartRate()
    }
    
    // MARK: - Methods
    
    func fetchWorkout(with uuid: UUID) -> CDWorkout? {
        let fetchRequest: NSFetchRequest<CDWorkout> = NSFetchRequest(entityName: "\(CDWorkout.self)")
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid.uuidString)
        
        guard let workouts = try? context.fetch(fetchRequest) else { return nil }
        
        return workouts.first
    }
    
    func fetchWorkouts(start: Date?,
                       end: Date?) -> [CDWorkout] {
        let fetchRequest: NSFetchRequest<CDWorkout> = NSFetchRequest(entityName: "\(CDWorkout.self)")
        
        if let start = start,
           let end = end {
            fetchRequest.predicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", start as NSDate, end as NSDate)
        }
        
        guard let workouts = try? context.fetch(fetchRequest) else { return [] }
        
        return workouts
    }
    
    func fetchUser() -> CDUser? {
        let fetchRequest: NSFetchRequest<CDUser> = NSFetchRequest(entityName: "\(CDUser.self)")
        
        guard let users = try? context.fetch(fetchRequest) else { return nil }
        
        return users.first
    }
    
    func save(workout: HKWorkout,
              hearthRate: [HKQuantitySample],
              distanceWalkingRunning: [HKQuantitySample],
              stepCount: [HKQuantitySample],
              basalEnergyBurned: [HKQuantitySample],
              activeEnergyBurned: [HKQuantitySample]) {
        let newWorkout = CDWorkout(context: context)
        newWorkout.uuid = workout.uuid
        newWorkout.startDate = workout.startDate
        newWorkout.endDate = workout.endDate
        newWorkout.duration = workout.duration
        
        if let totalDistance = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) {
            newWorkout.totalDistance = totalDistance
        }
        
        if let totalEnergyBurned = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
            newWorkout.totalEnergyBurned = totalEnergyBurned
        }
        
        if let metabolicEquivalentTaskQuantity = workout.metadata?[HKMetadataKeyAverageMETs] as? HKQuantity {
            newWorkout.metabolicEquivalentTask = metabolicEquivalentTaskQuantity.doubleValue(for: HKUnit(from: "kcal/hr·kg"))
        }
        
        if let isIndoorWorkout = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool {
            newWorkout.isIndoorWorkout = isIndoorWorkout
        }
        
        if let weatherHumidityQuantity = workout.metadata?[HKMetadataKeyWeatherHumidity] as? HKQuantity {
            newWorkout.weatherHumidity = weatherHumidityQuantity.doubleValue(for: .percent())
        }
        
        if let weatherTemperatureQuantity = workout.metadata?[HKMetadataKeyWeatherTemperature] as? HKQuantity {
            newWorkout.weatherTemperature = weatherTemperatureQuantity.doubleValue(for: .degreeFahrenheit())
        }
        
        newWorkout.hearthRate = NSSet(array: hearthRate.map { convertHearthRate(quantitySample: $0) })
        newWorkout.distanceWalkingRunning = NSSet(array: distanceWalkingRunning.map { convertDistanceWalkingRunning(quantitySample: $0) })
        newWorkout.stepCount = NSSet(array: stepCount.map { convertStepCount(quantitySample: $0) })
        newWorkout.basalEnergyBurned = NSSet(array: basalEnergyBurned.map { convertEnergyBurned(quantitySample: $0) })
        newWorkout.activeEnergyBurned = NSSet(array: activeEnergyBurned.map { convertEnergyBurned(quantitySample: $0) })

        saveIfNeeded()
        
        updateUserMaxHeartRate()
    }
    
    func eraseAllData() {
        let storeContainer = persistentContainer.persistentStoreCoordinator
        
        for store in storeContainer.persistentStores {
            guard let url = store.url else { continue }

            try? storeContainer.destroyPersistentStore(at: url,
                                                       ofType: store.type,
                                                       options: nil)
            
        }
        
        initDatabase()
    }
    
    // MARK: - Private methods
    
    private func initDatabase() {
        persistentContainer = NSPersistentContainer(name: "Running")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        context = persistentContainer.newBackgroundContext()
    }
    
    private func saveIfNeeded() {
        guard context.hasChanges else { return }
    
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func convertHearthRate(quantitySample: HKQuantitySample) -> CDQuantitySample {
        let newHearthRate = CDQuantitySample(context: context)
        newHearthRate.uuid = quantitySample.uuid
        newHearthRate.startDate = quantitySample.startDate
        newHearthRate.endDate = quantitySample.endDate
        newHearthRate.value = quantitySample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
        
        return newHearthRate
    }
    
    private func convertDistanceWalkingRunning(quantitySample: HKQuantitySample) -> CDQuantitySample {
        let newHearthRate = CDQuantitySample(context: context)
        newHearthRate.uuid = quantitySample.uuid
        newHearthRate.startDate = quantitySample.startDate
        newHearthRate.endDate = quantitySample.endDate
        newHearthRate.value = quantitySample.quantity.doubleValue(for: .meter())
        
        return newHearthRate
    }
    
    private func convertStepCount(quantitySample: HKQuantitySample) -> CDQuantitySample {
        let newHearthRate = CDQuantitySample(context: context)
        newHearthRate.uuid = quantitySample.uuid
        newHearthRate.startDate = quantitySample.startDate
        newHearthRate.endDate = quantitySample.endDate
        newHearthRate.value = quantitySample.quantity.doubleValue(for: .count())
        
        return newHearthRate
    }
    
    private func convertEnergyBurned(quantitySample: HKQuantitySample) -> CDQuantitySample {
        let newHearthRate = CDQuantitySample(context: context)
        newHearthRate.uuid = quantitySample.uuid
        newHearthRate.startDate = quantitySample.startDate
        newHearthRate.endDate = quantitySample.endDate
        newHearthRate.value = quantitySample.quantity.doubleValue(for: .kilocalorie())
        
        return newHearthRate
    }
    
    private func updateUserMaxHeartRate() {
        let maxHeartRate = fetchWorkouts(start: .add(days: -30, to: .today),
                                         end: .today)
            .compactMap { $0.hearthRate?.allObjects as? [CDQuantitySample] }
            .flatMap { $0 }
            .map { $0.value }
            .max() ?? 0
        
        let user: CDUser
        
        if let savedUser = fetchUser() {
            user = savedUser
        } else {
            user = CDUser(context: context)
        }
        
        user.maxHearthRate = maxHeartRate
        
        saveIfNeeded()
    }
}
