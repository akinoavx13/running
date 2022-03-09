//
//  Date+Extensions.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import Foundation

extension Date {
    
    // MARK: - Properties
    
    static var lastWeek: Date? { ago(days: 7, to: .now) }
        
    // MARK: - Methods
    
    static func ago(days: Int, to date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: -days, to: date)
    }
}
