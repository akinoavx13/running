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
    func save(workout: HKWorkout) -> Bool
}

final class DatabaseService: DatabaseServiceProtocol {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Lifecycle
    
    init() {
        let container = NSPersistentContainer(name: "Running")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        context = container.newBackgroundContext()
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
    
    func save(workout: HKWorkout) -> Bool {
        let newWorkout = CDWorkout(context: context)
        newWorkout.uuid = workout.uuid
        
        return saveIfNeeded()
    }
}
