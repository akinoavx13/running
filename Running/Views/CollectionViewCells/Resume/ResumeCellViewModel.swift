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
        let intensity: Int = Int(workouts.map { $0.metabolicEquivalentTask }.reduce(0, +))
        let distance = workouts.map { $0.totalDistance }.reduce(0, +)
        let durationInSeconds = workouts.map { $0.duration }.reduce(0, +)
        
        let minutes: Int = Int(durationInSeconds.secondsToMinutes)
        let seconds: Int = Int(durationInSeconds) % 60

        self.intensity = "\(intensity) METs"
        self.distance = formatterService.format(value: distance, accuracy: 1) + " km"
        self.duration = "\(minutes):\(seconds) min"
    }
}
