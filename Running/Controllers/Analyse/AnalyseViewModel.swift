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
        let workouts = await databaseService.fetchWorkouts(start: .ago(days: 6, to: .now),
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
        case intensity(_ for: SectionHeaderReusableViewModel),
             resume(_ for: SectionHeaderReusableViewModel)
    }
    
    enum Cell {
        case intensity(_ for: IntensityCellViewModel),
             resume(_ for: ResumeCellViewModel)
    }
    
    // MARK: - Private methods
    
    private func configureComposition(workouts: [CDWorkout] = []) {
        var sections = [Section]()
        
        if let intensitySection = configureIntensitySection(workouts: workouts) {
            sections.append(intensitySection)
        }
    
        sections.append(configureResumeSection(workouts: workouts))
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection(workouts: [CDWorkout]) -> Section? {        
        var values: [(x: Double, y: Double)] = []
        var xValues: [String] = []

        Date.getLastDays(days: 6, from: Date())
            .enumerated()
            .forEach { iterator in
                if let workout = workouts.first(where: { ($0.startDate?.isIn(date: iterator.element)) ?? false }) {
                    values.append((x: Double(iterator.offset), y: workout.metabolicEquivalentTask))
                } else {
                    values.append((x: Double(iterator.offset), y: 0))
                }
                xValues.append(formatterService.format(date: iterator.element, with: "dd\nE"))
            }
        
        let cells: [Cell] = [.intensity(IntensityCellViewModel(values: values, xValues: xValues))]
        
        return .section(.intensity(SectionHeaderReusableViewModel(title: R.string.localizable.intensity(),
                                                                  caption: nil)),
                        title: nil,
                        cells: cells)
    }
    
    private func configureResumeSection(workouts: [CDWorkout]) -> Section {
        let intensity: Int = Int(workouts.map { $0.metabolicEquivalentTask }.reduce(0, +))
        let distance = workouts.map { $0.totalDistance }.reduce(0, +)
        let durationInSeconds: Int = Int(workouts.map { $0.duration }.reduce(0, +))
        
        let minutes: Int = durationInSeconds / 60
        let seconds: Int = durationInSeconds % 60

        let cells: [Cell] = [.resume(ResumeCellViewModel(intensity: "\(intensity) METs",
                                                         distance: "\(formatterService.format(value: distance, accuracy: 1)) km",
                                                         duration: "\(minutes):\(seconds) min"))]
        
        return .section(.resume(SectionHeaderReusableViewModel(title: R.string.localizable.resume(),
                                                               caption: nil)),
                        title: nil,
                        cells: cells)
    }
}
