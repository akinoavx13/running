//
//  Date+Extensions.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import Foundation.NSDate

extension Date {
    
    // MARK: - Properties
    
    static var lastWeek: Date? { add(days: -7, to: .today) }
    static var yesterday: Date? { add(days: -1, to: .today) }
    static var today: Date? { Calendar.current.startOfDay(for: Date()) }
     
    // MARK: - Methods
    
    static func add(days: Int, to date: Date?) -> Date? {
        guard let date = date else { return nil }

        return Calendar.current.date(byAdding: .day,
                                     value: days,
                                     to: date)
    }
    
    static func getLastDays(days: Int, from date: Date?) -> [Date] {
        guard let date = date else { return [] }

        return (0...days)
            .reversed()
            .compactMap { index in .add(days: -index, to: date) }
    }
    
    func isIn(date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: self)
    }
}
