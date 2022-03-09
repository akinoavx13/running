//
//  LatestWorkoutCell.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import Reusable

final class LatestWorkoutCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var importButton: AnimateButton! {
        didSet { importButton.setTitle(R.string.localizable.import(), for: .normal) }
    }
    @IBOutlet private weak var checkIconImageView: UIImageView!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 48)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.text = nil
        timeLabel.text = nil
        importButton.isHidden = false
        checkIconImageView.isHidden = true
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: LatestWorkoutCellViewModel) {
        dateLabel.text = viewModel.date
        timeLabel.text = viewModel.time
        
        importButton.isHidden = viewModel.isImported
        checkIconImageView.isHidden = !viewModel.isImported
    }
}
