//
//  AnalyseViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import RxSwift
import RxCocoa

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
    
    // MARK: - Lifecycle
    
    init(actions: AnalyseViewModelActions,
         databaseService: DatabaseServiceProtocol) {
        self.actions = actions
        self.databaseService = databaseService
        
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
        
        sections.append(configureIntensitySection(workouts: workouts))
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection(workouts: [CDWorkout]) -> Section {
        let cells: [Cell] = [.intensity(IntensityCellViewModel())]
        
        return .section(.intensity,
                        title: nil,
                        cells: cells)
    }
}
