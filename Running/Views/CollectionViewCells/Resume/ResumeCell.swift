//
//  ResumeCell.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import UIKit
import Reusable

final class ResumeCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var intensityContainer: UIView! {
        didSet {
            intensityContainer.layer.cornerRadius = 4
            intensityContainer.layer.borderColor = Colors.accent.cgColor
            intensityContainer.layer.borderWidth = 1
        }
    }
    @IBOutlet private weak var intensityTitleLabel: UILabel! {
        didSet { intensityTitleLabel.text = R.string.localizable.intensity() }
    }
    @IBOutlet private weak var intensityValueLabel: UILabel!
    @IBOutlet private weak var intensityIconImageView: UIImageView!
    
    @IBOutlet private weak var distanceContainer: UIView! {
        didSet { distanceContainer.layer.cornerRadius = 4 }
    }
    @IBOutlet private weak var distanceTitleLabel: UILabel! {
        didSet { distanceTitleLabel.text = R.string.localizable.distance() }
    }
    @IBOutlet private weak var distanceValueLabel: UILabel!
    @IBOutlet private weak var distanceIconImageView: UIImageView!
    
    @IBOutlet private weak var durationContainer: UIView! {
        didSet { durationContainer.layer.cornerRadius = 4 }
    }
    @IBOutlet private weak var durationTitleLabel: UILabel! {
        didSet { durationTitleLabel.text = R.string.localizable.duration() }
    }
    @IBOutlet private weak var durationValueLabel: UILabel!
    @IBOutlet private weak var durationIconImageView: UIImageView!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 55)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        intensityValueLabel.text = nil
        distanceValueLabel.text = nil
        durationValueLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: ResumeCellViewModel) {
        intensityValueLabel.text = viewModel.intensity
        distanceValueLabel.text = viewModel.distance
        durationValueLabel.text = viewModel.duration
    }
}
