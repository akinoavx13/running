//
//  LatestWorkoutCell.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import Reusable

protocol LatestWorkoutCellDelegate: AnyObject {
    func latestWorkoutCell(_ sender: LatestWorkoutCell,
                           importButtonDidTap button: AnimateButton,
                           uuid: UUID)
}

final class LatestWorkoutCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var containerView: UIView! {
        didSet { containerView.layer.cornerRadius = 8 }
    }
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var importButton: AnimateButton! {
        didSet { importButton.setTitle(R.string.localizable.import(), for: .normal) }
    }
    @IBOutlet private weak var checkIconImageView: UIImageView!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 60)
    }
    
    weak var delegate: LatestWorkoutCellDelegate?
    
    private var uuid: UUID?
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.text = nil
        timeLabel.text = nil
        distanceLabel.text = nil
        importButton.isHidden = false
        checkIconImageView.isHidden = true
        
        uuid = nil
        delegate = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: LatestWorkoutCellViewModel) {
        dateLabel.text = viewModel.date
        timeLabel.text = viewModel.time
        distanceLabel.text = viewModel.distance
        
        importButton.isHidden = viewModel.isImported
        checkIconImageView.isHidden = !viewModel.isImported
        
        uuid = viewModel.uuid
    }
    
    // MARK: - Actions
    
    @IBAction private func importButtonDidTap(_ sender: AnimateButton) {
        guard let uuid = uuid else { return }

        delegate?.latestWorkoutCell(self,
                                    importButtonDidTap: sender,
                                    uuid: uuid)
    }
}
