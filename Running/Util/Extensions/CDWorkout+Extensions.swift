//
//  CDWorkout+Extensions.swift
//  Running
//
//  Created by Maxime Maheo on 14/03/2022.
//

import CoreGraphics

extension CDWorkout {
    
    // MARK: - Methods
    
    func rss(maxHeartRate: Double) -> Double {
        guard let heartRates = hearthRate?.allObjects as? [CDQuantitySample] else { return 0 }
        
        let durationInMinutes = duration / 60
        let averageHeartRate = heartRates
            .map { $0.value }
            .filter { $0 > 0 }
            .average
        
        return pow((100 * durationInMinutes * (averageHeartRate / maxHeartRate)), 0.52936)
    }
    
}
