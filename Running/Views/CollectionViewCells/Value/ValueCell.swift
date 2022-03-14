//
//  ValueCell.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import UIKit
import Reusable

final class ValueCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
   
    @IBOutlet private weak var containerView: UIView! {
        didSet { containerView.layer.cornerRadius = 8 }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 55)
    }
        
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: ValueCellViewModel) {
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
    }
}
