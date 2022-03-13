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
    func update(resumeType: AnalyseViewModel.ResumeType)
}

final class AnalyseViewModel: AnalyseViewModelProtocol {
    
    enum ResumeType {
        case intensity,
             distance,
             duration
        
        // MARK: - Properties
        
        var title: String {
            switch self {
            case .intensity: return R.string.localizable.intensity()
            case .distance: return R.string.localizable.distance()
            case .duration: return R.string.localizable.duration()
            }
        }
    }
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private var resumeType: ResumeType = .intensity
    private var workouts: [CDWorkout] = []
    
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
        workouts = await databaseService.fetchWorkouts(start: .ago(days: 6, to: .now),
                                                           end: .now)
        
        configureComposition(workouts: workouts,
                             resumeType: resumeType)
    }
    
    func update(resumeType: ResumeType) {
        self.resumeType = resumeType
        
        configureComposition(workouts: workouts,
                             resumeType: resumeType)
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
    
    private func configureComposition(workouts: [CDWorkout] = [],
                                      resumeType: ResumeType? = nil) {
        var sections = [Section]()
        
        if let intensitySection = configureIntensitySection(workouts: workouts,
                                                            resumeType: resumeType) {
            sections.append(intensitySection)
        }
    
        sections.append(configureResumeSection(workouts: workouts))
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection(workouts: [CDWorkout],
                                           resumeType: ResumeType?) -> Section? {
        guard let resumeType = resumeType else { return nil }
        
        var values: [(x: Double, y: Double)] = []
        var xValues: [String] = []

        Date.getLastDays(days: 6, from: Date())
            .enumerated()
            .forEach { iterator in
                if let workout = workouts.first(where: { ($0.startDate?.isIn(date: iterator.element)) ?? false }) {
                    switch resumeType {
                    case .intensity: values.append((x: Double(iterator.offset), y: workout.metabolicEquivalentTask))
                    case .distance: values.append((x: Double(iterator.offset), y: workout.totalDistance))
                    case .duration: values.append((x: Double(iterator.offset), y: workout.duration.secondsToMinutes))
                    }
                } else {
                    values.append((x: Double(iterator.offset), y: 0))
                }
                xValues.append(formatterService.format(date: iterator.element, with: "dd\nE"))
            }
        
        let cells: [Cell] = [.intensity(IntensityCellViewModel(values: values,
                                                               xValues: xValues,
                                                               resumeType: resumeType))]
        
        return .section(.intensity(SectionHeaderReusableViewModel(title: resumeType.title,
                                                                  caption: nil)),
                        title: nil,
                        cells: cells)
    }
    
    private func configureResumeSection(workouts: [CDWorkout]) -> Section {
        let intensity: Int = Int(workouts.map { $0.metabolicEquivalentTask }.reduce(0, +))
        let distance = workouts.map { $0.totalDistance }.reduce(0, +)
        let durationInSeconds = workouts.map { $0.duration }.reduce(0, +)
        
        let minutes: Int = Int(durationInSeconds.secondsToMinutes)
        let seconds: Int = Int(durationInSeconds) % 60

        let cells: [Cell] = [.resume(ResumeCellViewModel(intensity: "\(intensity) METs",
                                                         distance: "\(formatterService.format(value: distance, accuracy: 1)) km",
                                                         duration: "\(minutes):\(seconds) min"))]
        
        return .section(.resume(SectionHeaderReusableViewModel(title: R.string.localizable.resume(),
                                                               caption: nil)),
                        title: nil,
                        cells: cells)
    }
}
