//
//  SectionHeaderReusableView.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

import UIKit
import Reusable

final class SectionHeaderReusableView: UICollectionReusableView, NibReusable {

    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var captionLabel: UILabel!
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 44)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        captionLabel.text = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: SectionHeaderReusableViewModel) {
        titleLabel.text = viewModel.title
        captionLabel.text = viewModel.caption
    }
}
