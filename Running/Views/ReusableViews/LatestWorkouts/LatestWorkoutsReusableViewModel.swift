//
//  LatestWorkoutsReusableViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

final class LatestWorkoutsReusableViewModel {
    
    // MARK: - Properties
    
    let nbWorkouts: String
    
    // MARK: - Lifecycle
    
    init(nbWorkouts: Int) {
        self.nbWorkouts = "\(nbWorkouts)"
    }
}
