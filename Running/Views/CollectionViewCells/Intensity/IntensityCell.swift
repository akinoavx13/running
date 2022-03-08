//
//  IntensityCell.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import Reusable

final class IntensityCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 300)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: IntensityCellViewModel) {
        
    }
}
