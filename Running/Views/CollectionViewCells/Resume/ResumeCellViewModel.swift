//
//  ResumeCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

final class ResumeCellViewModel {
    
    // MARK: - Properties
    
    let intensity: String
    let distance: String
    let duration: String
    
    // MARK: - Lifecycle
    
    init(workouts: [CDWorkout],
         formatterService: FormatterServiceProtocol) {
        // TODO: Calculate RSS
        let intensity: Int = Int(workouts.map { $0.metabolicEquivalentTask }.reduce(0, +))
        let distance = workouts.map { $0.totalDistance }.reduce(0, +)
        let durationInSeconds = workouts.map { $0.duration }.reduce(0, +)

        let hours: Int = Int(durationInSeconds) / 3600
        let minutes: Int = (Int(durationInSeconds) % 3600) / 60
        let seconds: Int = (Int(durationInSeconds) % 3600) % 60

        self.intensity = "\(intensity) METs"
        self.distance = formatterService.format(value: distance, accuracy: 1) + " km"
        
        if hours > 0 {
            self.duration = "\(hours)h \(minutes) min"
        } else {
            self.duration = "\(minutes)min \(seconds) sec"
        }
    }
}
