//
//  IntensityCellViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

final class IntensityCellViewModel {
    
    // MARK: - Properties
    
    let values: [(x: Double, y: Double)]
    let xValues: [String]
    let resumeType: AnalyseViewModel.ResumeType
    
    // MARK: - Lifecycle
    
    init(values: [(x: Double, y: Double)],
         xValues: [String],
         resumeType: AnalyseViewModel.ResumeType) {
        self.values = values
        self.xValues = xValues
        self.resumeType = resumeType
    }
}
