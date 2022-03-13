//
//  SuggestedIntensityCell.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import UIKit
import Reusable

final class SuggestedIntensityCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 55)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: SuggestedIntensityCellViewModel) {
        
    }
}
