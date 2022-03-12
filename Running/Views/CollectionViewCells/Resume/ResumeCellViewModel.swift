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
    
    init(intensity: String,
         distance: String,
         duration: String) {
        self.intensity = intensity
        self.distance = distance
        self.duration = duration
    }
}
