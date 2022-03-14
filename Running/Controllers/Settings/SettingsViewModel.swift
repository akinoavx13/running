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
        guard let today = Date.today,
              let startDate = Date.add(days: -30, to: today)
        else { return }
        
        let workouts = await importService.availableForImport(activity: .running,
                                                              start: startDate,
                                                              end: today)
        let user = databaseService.fetchUser()

        configureComposition(workouts: workouts,
                             user: user)
    }
    
    func importWorkout(uuid: UUID) async {
        await importService.importWorkout(uuid: uuid)
        
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
        case users(_ for: SectionHeaderReusableViewModel),
             latestWorkouts(_ for: SectionHeaderReusableViewModel),
             eraseData
    }
    
    enum Cell {
        case latestWorkout(_ for: LatestWorkoutCellViewModel),
             eraseData,
             value(_ for: ValueCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition(workouts: [HKWorkout] = [],
                                      user: CDUser? = nil) {
        var sections = [Section]()
        
        if let userSection = configureUserSection(user: user) {
            sections.append(userSection)
        }
        
        sections.append(configureLatestWorkoutsSection(workouts: workouts))
        sections.append(configureEraseDataSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureUserSection(user: CDUser?) -> Section? {
        guard let user = user else { return nil }
        
        let cells: [Cell] = [.value(ValueCellViewModel(title: R.string.localizable.max_heart_rate(),
                                                       value: "\(Int(user.maxHearthRate)) bpm"))]
        
        return .section(.users(SectionHeaderReusableViewModel(title: R.string.localizable.user(),
                                                              caption: R.string.localizable.last_x_days(30))),
                        cells: cells)
    }
    
    private func configureLatestWorkoutsSection(workouts: [HKWorkout]) -> Section {
        let cells: [Cell] = workouts
            .map { .latestWorkout(LatestWorkoutCellViewModel(workout: $0,
                                                             formatterService: formatterService,
                                                             importService: importService)) }
        
        return .section(.latestWorkouts(SectionHeaderReusableViewModel(title: R.string.localizable.latest_workouts(),
                                                                       caption: "\(workouts.count)")),
                        cells: cells)
    }
    
    private func configureEraseDataSection() -> Section {
        .section(.eraseData,
                 cells: [.eraseData])
    }
}
