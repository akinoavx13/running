//
//  AnalyseView.swift
//  Running
//
//  Created by Maxime Maheo on 06/03/2022.
//

import SwiftUI

struct AnalyseView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel = AnalyseViewModel()
    
    // MARK: - Body
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

#if DEBUG

struct AnalyseView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyseView()
    }
}

#endif
