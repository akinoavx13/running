//
//  LatestWorkoutCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

final class LatestWorkoutCellViewModel {
    
    // MARK: - Properties
    
    let date: String
    let time: String
    let isImported: Bool
    
    // MARK: - Lifecycle
    
    init(date: String,
         time: String,
         isImported: Bool) {
        self.date = date
        self.time = time
        self.isImported = isImported
    }
}
