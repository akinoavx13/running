//
//  LatestWorkoutsReusableView.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

import UIKit
import Reusable

final class LatestWorkoutsReusableView: UICollectionReusableView, NibReusable {

    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet { titleLabel.text = R.string.localizable.workouts_in_the_last_30_days() }
    }
    @IBOutlet private weak var nbWorkoutLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 44)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nbWorkoutLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: LatestWorkoutsReusableViewModel) {
        nbWorkoutLabel.text = viewModel.nbWorkouts
    }
}
