//
//  ResumeCell.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import UIKit
import Reusable

protocol ResumeCellDelegate: AnyObject {
    func resumeCell(_ sender: ResumeCell,
                    intensityContainerDidTap view: UIView)
    func resumeCell(_ sender: ResumeCell,
                    distanceContainerDidTap view: UIView)
    func resumeCell(_ sender: ResumeCell,
                    durationContainerDidTap view: UIView)
}

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
        didSet {
            distanceContainer.layer.cornerRadius = 4
            distanceContainer.layer.borderColor = Colors.blue.cgColor
        }
    }
    @IBOutlet private weak var distanceTitleLabel: UILabel! {
        didSet { distanceTitleLabel.text = R.string.localizable.distance() }
    }
    @IBOutlet private weak var distanceValueLabel: UILabel!
    @IBOutlet private weak var distanceIconImageView: UIImageView!
    
    @IBOutlet private weak var durationContainer: UIView! {
        didSet {
            durationContainer.layer.cornerRadius = 4
            durationContainer.layer.borderColor = Colors.green.cgColor
        }
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
    
    weak var delegate: ResumeCellDelegate?
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        intensityValueLabel.text = nil
        distanceValueLabel.text = nil
        durationValueLabel.text = nil
        
        delegate = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: ResumeCellViewModel) {
        intensityValueLabel.text = viewModel.intensity
        distanceValueLabel.text = viewModel.distance
        durationValueLabel.text = viewModel.duration
        
        intensityContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(intensityDidTap(_:))))
        distanceContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(distanceDidTap(_:))))
        durationContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(durationDidTap(_:))))
    }
    
    // MARK: - Actions
    
    @objc private func intensityDidTap(_ sender: UITapGestureRecognizer) {
        intensityContainer.layer.borderWidth = 1
        intensityIconImageView.tintColor = Colors.accent
        intensityIconImageView.alpha = 1
        
        distanceContainer.layer.borderWidth = 0
        distanceIconImageView.tintColor = .white
        distanceIconImageView.alpha = 0.5
        
        durationContainer.layer.borderWidth = 0
        durationIconImageView.tintColor = .white
        durationIconImageView.alpha = 0.5
        
        delegate?.resumeCell(self, intensityContainerDidTap: intensityContainer)
    }
    
    @objc private func distanceDidTap(_ sender: UITapGestureRecognizer) {
        distanceContainer.layer.borderWidth = 1
        distanceIconImageView.tintColor = Colors.blue
        distanceIconImageView.alpha = 1

        intensityContainer.layer.borderWidth = 0
        intensityIconImageView.tintColor = .white
        intensityIconImageView.alpha = 0.5
        
        durationContainer.layer.borderWidth = 0
        durationIconImageView.tintColor = .white
        durationIconImageView.alpha = 0.5
        
        delegate?.resumeCell(self, distanceContainerDidTap: intensityContainer)
    }
    
    @objc private func durationDidTap(_ sender: UITapGestureRecognizer) {
        durationContainer.layer.borderWidth = 1
        durationIconImageView.tintColor = Colors.green
        durationIconImageView.alpha = 1

        intensityContainer.layer.borderWidth = 0
        intensityIconImageView.tintColor = .white
        intensityIconImageView.alpha = 0.5
        
        distanceContainer.layer.borderWidth = 0
        distanceIconImageView.tintColor = .white
        distanceIconImageView.alpha = 0.5
        
        delegate?.resumeCell(self, durationContainerDidTap: intensityContainer)
    }
}
