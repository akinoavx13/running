//
//  ValueCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

final class ValueCellViewModel {
    
    // MARK: - Properties
    
    let title: String
    let value: String
    
    // MARK: - Lifecycle
    
    init(title: String,
         value: String) {
        self.title = title
        self.value = value
    }
}
