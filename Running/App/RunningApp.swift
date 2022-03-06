//
//  RunningApp.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

import SwiftUI

@main
struct RunningApp: App {
    
    // MARK: - Properties
    
    private let dependencyManager = DependencyManager()

    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            AnalyseView()
        }
    }
}
