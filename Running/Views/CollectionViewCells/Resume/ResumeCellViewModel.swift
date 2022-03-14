//
//  ResumeCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import Foundation.NSDate

final class ResumeCellViewModel {
    
    // MARK: - Properties
    
    let intensity: String
    let distance: String
    let duration: String
    
    // MARK: - Lifecycle
    
    init(workouts: [CDWorkout],
         maxHeartRate: Double,
         formatterService: FormatterServiceProtocol) {
        var intensity: Double = 0
        var distance: Double = 0
        var durationInSeconds: Double = 0
        
        Date.getLastDays(days: 6, from: .today)
            .enumerated()
            .forEach { iterator in
                if let workout = workouts.first(where: { ($0.startDate?.isIn(date: iterator.element)) ?? false }) {
                    intensity += workout.rss(maxHeartRate: maxHeartRate)
                    distance += workout.totalDistance
                    durationInSeconds += workout.duration
                }
            }
        
        self.intensity = "\(Int(intensity)) RSS"
        self.distance = formatterService.format(value: distance, accuracy: 1) + " km"

        let hours: Int = Int(durationInSeconds) / 3600
        let minutes: Int = (Int(durationInSeconds) % 3600) / 60
        let seconds: Int = (Int(durationInSeconds) % 3600) % 60
        if hours > 0 {
            self.duration = "\(hours)h \(minutes) min"
        } else {
            self.duration = "\(minutes)min \(seconds) sec"
        }
    }
}
