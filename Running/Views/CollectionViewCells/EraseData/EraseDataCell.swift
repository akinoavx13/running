//
//  EraseDataCell.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import Reusable

protocol EraseDataCellDelegate: AnyObject {
    func eraseDataCell(_ sender: EraseDataCell,
                       eraseButtonDidTap button: AnimateButton)
}

final class EraseDataCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var eraseButton: AnimateButton! {
        didSet { eraseButton.setTitle(R.string.localizable.erase_all_data(), for: .normal) }
    }
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 44)
    }

    weak var delegate: EraseDataCellDelegate?
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
    }
    
    // MARK: - Actions
    
    @IBAction private func eraseButtonDidTap(_ sender: AnimateButton) {
        delegate?.eraseDataCell(self, eraseButtonDidTap: sender)
    }
}
