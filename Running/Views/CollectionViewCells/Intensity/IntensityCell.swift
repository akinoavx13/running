//
//  IntensityCell.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import UIKit
import Reusable
import Charts

final class IntensityCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var chartView: BarChartView! {
        didSet {
            chartView.dragEnabled = false
            chartView.doubleTapToZoomEnabled = false
            chartView.legend.enabled = false
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet { titleLabel.text = R.string.localizable.intensity() }
    }
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 250)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        chartView.data = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: IntensityCellViewModel) {
        let chartDataSet = BarChartDataSet(entries: viewModel.values.map { BarChartDataEntry(x: $0.x, y: $0.y) })
        chartDataSet.colors = [viewModel.resumeType.color]
        chartDataSet.drawValuesEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.6)
        xAxis.labelPosition = .bottom
        xAxis.labelCount = viewModel.xValues.count
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.xValues)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        leftAxis.labelTextColor = UIColor.white.withAlphaComponent(0.6)
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = UIColor.white.withAlphaComponent(0.15)
        leftAxis.gridLineWidth = 1
        leftAxis.gridLineDashLengths = [2, 12]
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        chartView.data = BarChartData(dataSet: chartDataSet)
    }
}
