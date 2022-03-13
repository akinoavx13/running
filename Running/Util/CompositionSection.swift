//
//  CompositionSection.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

public struct CompositionSection<T, V> {
    
    // MARK: - Properties
    
    var count: Int { cells.count }
    
    let type: T
    private let cells: [V]

    // MARK: - Methods
    
    static func section(_ type: T,
                        cells: [V] = []) -> CompositionSection<T, V> {
        CompositionSection(type: type,
                           cells: cells)
    }

    func cellForIndex(_ index: Int) -> V? {
        guard index < cells.count else { return nil }
        
        return cells[index]
    }
}
