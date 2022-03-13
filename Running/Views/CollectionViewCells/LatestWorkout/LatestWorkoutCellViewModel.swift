//
//  LatestWorkoutCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import Foundation.NSUUID
import HealthKit.HKWorkout

final class LatestWorkoutCellViewModel {
    
    // MARK: - Properties
    
    let uuid: UUID
    let date: String
    let time: String
    let distance: String
    let isImported: Bool
    
    // MARK: - Lifecycle
    
    init(workout: HKWorkout,
         formatterService: FormatterServiceProtocol,
         importService: ImportServiceProtocol) {
        self.uuid = workout.uuid
        self.date = formatterService.format(date: workout.startDate,
                                            dateStyle: .short,
                                            timeStyle: .none)
        self.time = formatterService.format(date: workout.startDate,
                                            dateStyle: .none,
                                            timeStyle: .short)
        self.distance = formatterService.format(value: workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0,
                                                accuracy: 2) + " km"
        self.isImported = importService.isImported(uuid: workout.uuid)
    }
}
