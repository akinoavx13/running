//
//  Array+Extensions.swift
//  Running
//
//  Created by Maxime Maheo on 13/03/2022.
//

extension Array where Element: BinaryInteger {
    var average: Double {
        if isEmpty {
            return 0.0
        } else {
            let sum = reduce(0, +)
            return Double(sum) / Double(count)
        }
    }
}

extension Array where Element: BinaryFloatingPoint {
    var average: Double {
        if isEmpty {
            return 0.0
        } else {
            let sum = reduce(0, +)
            return Double(sum) / Double(count)
        }
    }
}
