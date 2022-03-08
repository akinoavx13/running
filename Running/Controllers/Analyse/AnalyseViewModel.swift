//
//  AnalyseViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

struct AnalyseViewModelActions { }

protocol AnalyseViewModelProtocol: AnyObject { }

final class AnalyseViewModel: AnalyseViewModelProtocol {
    
    // MARK: - Properties
    
    private let actions: AnalyseViewModelActions
    
    // MARK: - Lifecycle
    
    init(actions: AnalyseViewModelActions) {
        self.actions = actions
    }
}
