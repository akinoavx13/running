//
//  IntensityCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import Foundation.NSDate

final class IntensityCellViewModel {
    
    // MARK: - Properties
    
    let values: [(x: Double, y: Double)]
    let xValues: [String]
    let resumeType: AnalyseViewModel.ResumeType
    
    // MARK: - Lifecycle
    
    init(workouts: [CDWorkout],
         resumeType: AnalyseViewModel.ResumeType,
         maxHeartRate: Double,
         formatterService: FormatterServiceProtocol) {
        self.resumeType = resumeType
        
        var values: [(x: Double, y: Double)] = []
        var xValues: [String] = []
        
        Date.getLastDays(days: 6, from: .today)
            .enumerated()
            .forEach { iterator in
                if let workout = workouts.first(where: { ($0.startDate?.isIn(date: iterator.element)) ?? false }) {
                    switch resumeType {
                    case .intensity: values.append((x: Double(iterator.offset), y: workout.rss(maxHeartRate: maxHeartRate)))
                    case .distance: values.append((x: Double(iterator.offset), y: workout.totalDistance))
                    case .duration: values.append((x: Double(iterator.offset), y: workout.duration.secondsToMinutes))
                    }
                } else {
                    values.append((x: Double(iterator.offset), y: 0))
                }
                xValues.append(formatterService.format(date: iterator.element, with: "dd\nE"))
            }
        
        self.values = values
        self.xValues = xValues
    }
}
