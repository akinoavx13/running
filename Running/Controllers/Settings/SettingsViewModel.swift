//
//  SettingsViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import RxSwift
import RxCocoa

struct SettingsViewModelActions { }

protocol SettingsViewModelProtocol: AnyObject {

    // MARK: - Properties
    
    var composition: Driver<SettingsViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func refresh() async
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: SettingsViewModelActions
    
    // MARK: - Lifecycle
    
    init(actions: SettingsViewModelActions) {
        self.actions = actions
    }
    
    // MARK: - Methods
    
    func refresh() async {
        configureComposition()
    }
}

// MARK: - Composition -

extension SettingsViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case latestWorkouts(_ for: LatestWorkoutsReusableViewModel)
    }
    
    enum Cell {
        case latestWorkout(_ for: LatestWorkoutCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition() {
        var sections = [Section]()
        
        sections.append(configureLatestWorkoutsSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureLatestWorkoutsSection() -> Section {
        let cells: [Cell] = [.latestWorkout(LatestWorkoutCellViewModel(date: "3 October", time: "16:56", isImported: false)),
                             .latestWorkout(LatestWorkoutCellViewModel(date: "3 October", time: "16:56", isImported: false)),
                             .latestWorkout(LatestWorkoutCellViewModel(date: "3 October", time: "16:56", isImported: true))]
        
        return .section(.latestWorkouts(LatestWorkoutsReusableViewModel(nbWorkouts: 3)),
                        title: nil,
                        cells: cells)
    }
}
