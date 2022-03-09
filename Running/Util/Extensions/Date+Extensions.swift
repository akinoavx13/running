//
//  Date+Extensions.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import Foundation

extension Date {
    
    // MARK: - Properties
    
    static var lastWeek: Date? { remove(days: 7, to: .now) }
        
    // MARK: - Methods
    
    static func remove(days: Int, to date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: -days, to: date)
    }
}
