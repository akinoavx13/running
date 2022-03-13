//
//  SuggestedIntensityCell.swift
//  Running
//
//  Created by Maxime Maheo on 12/03/2022.
//

import UIKit
import Reusable
import Charts

final class SuggestedIntensityCell: UICollectionViewCell, NibReusable {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var suggestedCaptionLabel: UILabel! {
        didSet { suggestedCaptionLabel.text = R.string.localizable.suggested_range() }
    }
    @IBOutlet private weak var thisWeekCaptionLabel: UILabel! {
        didSet { thisWeekCaptionLabel.text = R.string.localizable.this_week() }
    }
    @IBOutlet private weak var containerView: UIView! {
        didSet { containerView.layer.cornerRadius = 8 }
    }
    @IBOutlet private weak var chartView: LineChartView! {
        didSet {
            chartView.dragEnabled = false
            chartView.doubleTapToZoomEnabled = false
            chartView.legend.enabled = false
        }
    }
    
    // MARK: - Properties
    
    static var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: 300)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        chartView.data = nil
    }
    
    // MARK: - Methods
    
    func bind(to viewModel: SuggestedIntensityCellViewModel) {
        let xAxis = chartView.xAxis
        xAxis.labelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.6)
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: viewModel.xValues)
        
        let upperLimit = ChartLimitLine(limit: 20)
        upperLimit.lineWidth = 2
        upperLimit.lineDashLengths = [8, 8]
        upperLimit.lineColor = Colors.accent

        let lowerLimit = ChartLimitLine(limit: 10)
        lowerLimit.lineWidth = 2
        lowerLimit.lineDashLengths = [8, 8]
        lowerLimit.lineColor = Colors.accent
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        leftAxis.labelTextColor = UIColor.white.withAlphaComponent(0.6)
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = UIColor.white.withAlphaComponent(0.15)
        leftAxis.gridLineWidth = 1
        leftAxis.gridLineDashLengths = [2, 12]
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(upperLimit)
        leftAxis.addLimitLine(lowerLimit)
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        let chartDataSet = LineChartDataSet(entries: viewModel.values.map { ChartDataEntry(x: $0.x, y: $0.y) })
        chartDataSet.circleRadius = 3
        chartDataSet.lineWidth = 2
        chartDataSet.setCircleColor(Colors.blue)
        chartDataSet.setColor(Colors.blue)
        chartDataSet.drawValuesEnabled = false

        chartView.data = LineChartData(dataSet: chartDataSet)
    }
}
