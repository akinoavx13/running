//
//  AnalyseViewModel.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

import RxSwift
import RxCocoa
import UIKit.UIColor

struct AnalyseViewModelActions { }

protocol AnalyseViewModelProtocol: AnyObject {

    // MARK: - Properties
    
    var composition: Driver<AnalyseViewModel.Composition> { get }
    
    // MARK: - Methods
    
    func refresh()
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
        
        var color: UIColor {
            switch self {
            case .intensity: return Colors.accent
            case .distance: return Colors.blue
            case .duration: return Colors.green
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
    
    func refresh() {
        workouts = databaseService.fetchWorkouts(start: .ago(days: 6, to: .today),
                                                 end: .today)
        
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
             resume(_ for: SectionHeaderReusableViewModel),
             suggestedIntensity(_ for: SectionHeaderReusableViewModel)
    }
    
    enum Cell {
        case intensity(_ for: IntensityCellViewModel),
             resume(_ for: ResumeCellViewModel),
             suggestedIntensity(_ for: SuggestedIntensityCellViewModel)
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
        sections.append(configureSuggestedIntensitySection(workouts: workouts))
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection(workouts: [CDWorkout],
                                           resumeType: ResumeType?) -> Section? {
        guard let resumeType = resumeType else { return nil }
        
        let cells: [Cell] = [.intensity(IntensityCellViewModel(workouts: workouts,
                                                               resumeType: resumeType,
                                                               formatterService: formatterService))]
        
        return .section(.intensity(SectionHeaderReusableViewModel(title: resumeType.title,
                                                                  caption: nil)),
                        cells: cells)
    }
    
    private func configureResumeSection(workouts: [CDWorkout]) -> Section {
        let cells: [Cell] = [.resume(ResumeCellViewModel(workouts: workouts,
                                                         formatterService: formatterService))]
        
        return .section(.resume(SectionHeaderReusableViewModel(title: R.string.localizable.resume(),
                                                               caption: nil)),
                        cells: cells)
    }
    
    private func configureSuggestedIntensitySection(workouts: [CDWorkout]) -> Section {
        let cells: [Cell] = [.suggestedIntensity(SuggestedIntensityCellViewModel(workouts: workouts,
                                                                                 formatterService: formatterService))]
        
        return .section(.suggestedIntensity(SectionHeaderReusableViewModel(title: R.string.localizable.suggested_intensity(),
                                                                           caption: nil)),
                        cells: cells)
    }
}
