//
//  AnalyseViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import RxSwift
import RxCocoa
import Foundation

struct AnalyseViewModelActions { }

protocol AnalyseViewModelProtocol: AnyObject {

    // MARK: - Properties
    
    var composition: Driver<AnalyseViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func refresh() async
}

final class AnalyseViewModel: AnalyseViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: AnalyseViewModelActions
    private let databaseService: DatabaseServiceProtocol
    private let formatterService: FormatterServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: AnalyseViewModelActions,
         databaseService: DatabaseServiceProtocol,
         formatterService: FormatterServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
        self.formatterService = formatterService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func refresh() async {
        let workouts = await databaseService.fetchWorkouts(start: .ago(days: 7, to: .now),
                                                           end: .now)
        
        configureComposition(workouts: workouts)
    }
}

// MARK: - Composition -

extension AnalyseViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case intensity
    }
    
    enum Cell {
        case intensity(_ for: IntensityCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition(workouts: [CDWorkout] = []) {
        var sections = [Section]()
        
        if let intensitySection = configureIntensitySection(workouts: workouts) {
            sections.append(intensitySection)
        }
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection(workouts: [CDWorkout]) -> Section? {
        guard !workouts.isEmpty else { return nil }
        
        var values: [(x: Double, y: Double)] = []
        var xValues: [String] = []

        Date.getLastDays(days: 7, from: Date())
            .enumerated()
            .forEach { iterator in
                workouts.forEach { workout in
                    if workout.startDate?.isIn(date: iterator.element) ?? false {
                        values.append((x: Double(iterator.offset), y: workout.metabolicEquivalentTask))
                    } else {
                        values.append((x: Double(iterator.offset), y: 0))
                    }
                    xValues.append(formatterService.format(date: iterator.element, with: "dd\nE"))
                }
            }
        
        let cells: [Cell] = [.intensity(IntensityCellViewModel(values: values, xValues: xValues))]
        
        return .section(.intensity,
                        title: nil,
                        cells: cells)
    }
}
