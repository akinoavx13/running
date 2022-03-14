//
//  SuggestedIntensityCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import Foundation.NSDate

final class SuggestedIntensityCellViewModel {
    
    // MARK: - Properties
    
    let values: [(x: Double, y: Double)]
    let xValues: [String]
    let upperLimit: Double
    let lowerLimit: Double
    
    // MARK: - Lifecycle
    
    init(workouts: [CDWorkout],
         formatterService: FormatterServiceProtocol) {
        var values: [(x: Double, y: Double)] = []
        var xValues: [String] = []
        
        Date.getLastDays(days: 6, from: .today)
            .enumerated()
            .forEach { iterator in
                let lastValue = values.last?.y ?? 0
                
                if let workout = workouts.first(where: { ($0.startDate?.isIn(date: iterator.element)) ?? false }) {
                    // TODO: Calculate RSS
                    values.append((x: Double(iterator.offset), y: lastValue + workout.metabolicEquivalentTask))
                } else {
                    values.append((x: Double(iterator.offset), y: lastValue))
                }
                xValues.append(formatterService.format(date: iterator.element, with: "dd\nE"))
            }
        
        let cumulativeIntensity = Date.getLastDays(days: 6, from: Date.lastWeek)
            .compactMap { date -> Double? in
                guard let workout = workouts.first(where: { ($0.startDate?.isIn(date: date)) ?? false }) else { return nil }
                // TODO: Calculate RSS
                return workout.metabolicEquivalentTask
            }
            .reduce(0, +)
        
        self.upperLimit = cumulativeIntensity * 1.1
        self.lowerLimit = cumulativeIntensity * 0.9
        
        self.values = values
        self.xValues = xValues
    }
}
