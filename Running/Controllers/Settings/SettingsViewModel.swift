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
    func importWorkout(uuid: UUID) async
    func eraseAllData() async
}

final class SettingsViewModel: SettingsViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: SettingsViewModelActions
    private let formatterService: FormatterServiceProtocol
    private let importService: ImportServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: SettingsViewModelActions,
         formatterService: FormatterServiceProtocol,
         importService: ImportServiceProtocol,
         databaseService: DatabaseServiceProtocol) {
        self.actions = actions
        self.formatterService = formatterService
        self.importService = importService
        self.databaseService = databaseService
        
        configureComposition()
    }
    
    // MARK: - Methods
    
    func refresh() async {
        guard let startDate = Date.ago(days: 30, to: .now) else { return }
        
        let workouts = await importService.availableForImport(activity: .running,
                                                              start: startDate,
                                                              end: .now)

        configureComposition(workouts: workouts)
    }
    
    func importWorkout(uuid: UUID) async {
        guard await importService.importWorkout(uuid: uuid) else { return }
        
        await refresh()
    }
    
    func eraseAllData() async {
        databaseService.eraseAllData()
        
        await refresh()
    }
}

// MARK: - Composition -

extension SettingsViewModel {
    typealias Section = CompositionSection<SectionType, Cell>
    
    struct Composition {
        var sections = [Section]()
    }
    
    enum SectionType {
        case latestWorkouts(_ for: LatestWorkoutsReusableViewModel),
             eraseData
    }
    
    enum Cell {
        case latestWorkout(_ for: LatestWorkoutCellViewModel),
             eraseData
    }
    
    // MARK: - Private methods
    
    private func configureComposition(workouts: [HKWorkout] = []) {
        var sections = [Section]()
        
        if let latestWorkoutsSection = configureLatestWorkoutsSection(workouts: workouts) {
            sections.append(latestWorkoutsSection)
        }
        
        sections.append(configureEraseDataSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureLatestWorkoutsSection(workouts: [HKWorkout]) -> Section? {
        guard !workouts.isEmpty else { return nil }
        
        let cells: [Cell] = workouts
            .map {
                let distance = $0.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                
                return .latestWorkout(LatestWorkoutCellViewModel(uuid: $0.uuid,
                                                                 date: formatterService.format(date: $0.startDate,
                                                                                               dateStyle: .short,
                                                                                               timeStyle: .none),
                                                                 time: formatterService.format(date: $0.startDate,
                                                                                               dateStyle: .none,
                                                                                               timeStyle: .short),
                                                                 distance: formatterService.format(value: distance,
                                                                                                   accuracy: 2),
                                                                 isImported: importService.isImported(uuid: $0.uuid)))
            }
        
        return .section(.latestWorkouts(LatestWorkoutsReusableViewModel(nbWorkouts: workouts.count)),
                        title: nil,
                        cells: cells)
    }
    
    private func configureEraseDataSection() -> Section {
        .section(.eraseData,
                 title: nil,
                 cells: [.eraseData])
    }
}
