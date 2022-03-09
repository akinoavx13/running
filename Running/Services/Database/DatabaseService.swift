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
    
    func saveIfNeeded() -> Bool
    func fetchWorkout(with uuid: UUID) -> CDWorkout?
    func save(workout: HKWorkout,
              hearthRate: [HKQuantitySample],
              distanceWalkingRunning: [HKQuantitySample],
              stepCount: [HKQuantitySample],
              basalEnergyBurned: [HKQuantitySample],
              activeEnergyBurned: [HKQuantitySample]) -> Bool
    func eraseAllData()
}

final class DatabaseService: DatabaseServiceProtocol {
    
    // MARK: - Properties
    
    private var persistentContainer: NSPersistentContainer!
    private var context: NSManagedObjectContext!
    
    // MARK: - Lifecycle
    
    init() {
        initDatabase()
    }
    
    // MARK: - Methods
    
    func saveIfNeeded() -> Bool {
        guard context.hasChanges else { return false }
    
        do {
            try context.save()
            
            return true
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchWorkout(with uuid: UUID) -> CDWorkout? {
        let fetchRequest: NSFetchRequest<CDWorkout> = NSFetchRequest(entityName: "\(CDWorkout.self)")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(CDWorkout.uuid), uuid.uuidString)
        
        guard let workouts = try? context.fetch(fetchRequest) else { return nil }
        
        return workouts.first
    }
    
    func save(workout: HKWorkout,
              hearthRate: [HKQuantitySample],
              distanceWalkingRunning: [HKQuantitySample],
              stepCount: [HKQuantitySample],
              basalEnergyBurned: [HKQuantitySample],
              activeEnergyBurned: [HKQuantitySample]) -> Bool {
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

        return saveIfNeeded()
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
}
