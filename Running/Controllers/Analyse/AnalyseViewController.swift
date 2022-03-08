//
//  AnalyseViewController.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit

final class AnalyseViewController: UIViewController {
    
    // MARK: - Outlets
    
    // MARK: - Properties
    
    var viewModel: AnalyseViewModelProtocol!
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: AnalyseViewModelProtocol) -> AnalyseViewController {
        guard let viewController = R.storyboard.analyseViewController().instantiateInitialViewController()
                as? AnalyseViewController
        else { fatalError("Could not instantiate AnalyseViewController.") }
        
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = R.string.localizable.analyse()
        
        bind(to: viewModel)
    }
    
    // MARK: - Private methods
    
    private func bind(to viewModel: AnalyseViewModelProtocol) {
        
    }
}
