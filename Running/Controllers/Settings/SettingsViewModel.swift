//
//  SettingsViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import RxSwift
import RxCocoa
import HealthKit

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
    private let healthKitService: HealthKitServiceProtocol
    private let formatterService: FormatterServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: SettingsViewModelActions,
         healthKitService: HealthKitServiceProtocol,
         formatterService: FormatterServiceProtocol) {
        self.actions = actions
        self.healthKitService = healthKitService
        self.formatterService = formatterService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func refresh() async {
        let workouts = await healthKitService.fetchWorkouts(activity: .running,
                                                            start: Date.ago(days: 30, to: .now),
                                                            end: .now)
        
        configureComposition(workouts: workouts)
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
    
    private func configureComposition(workouts: [HKWorkout] = []) {
        var sections = [Section]()
        
        if let latestWorkoutsSection = configureLatestWorkoutsSection(workouts: workouts) {
            sections.append(latestWorkoutsSection)
        }
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureLatestWorkoutsSection(workouts: [HKWorkout]) -> Section? {
        guard !workouts.isEmpty else { return nil }
        
        let cells: [Cell] = workouts
            .map {
                let distance = $0.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                
                return .latestWorkout(LatestWorkoutCellViewModel(date: formatterService.format(date: $0.startDate,
                                                                                               dateStyle: .short,
                                                                                               timeStyle: .none),
                                                                 time: formatterService.format(date: $0.startDate,
                                                                                               dateStyle: .none,
                                                                                               timeStyle: .short),
                                                                 distance: formatterService.format(value: distance,
                                                                                                   accuracy: 2),
                                                                 isImported: false))
            }
        
        return .section(.latestWorkouts(LatestWorkoutsReusableViewModel(nbWorkouts: workouts.count)),
                        title: nil,
                        cells: cells)
    }
}
