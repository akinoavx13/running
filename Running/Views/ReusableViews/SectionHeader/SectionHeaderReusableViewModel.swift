//
//  SectionHeaderReusableViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 09/03/2022.
//

final class SectionHeaderReusableViewModel {
    
    // MARK: - Properties
    
    let title: String
    let caption: String?
    
    // MARK: - Lifecycle
    
    init(title: String,
         caption: String?) {
        self.title = title
        self.caption = caption
    }
}
