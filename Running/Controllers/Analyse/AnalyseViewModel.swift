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
}

final class AnalyseViewModel: AnalyseViewModelProtocol {
    
    // MARK: - Properties
    
    lazy private(set) var composition: Driver<Composition> = compositionSubject.asDriver(onErrorDriveWith: .never())

    private let compositionSubject = ReplaySubject<Composition>.create(bufferSize: 1)
    
    private let actions: AnalyseViewModelActions
    private let healthKitService: HealthKitServiceProtocol
    
    // MARK: - Lifecycle
    
    init(actions: AnalyseViewModelActions,
         healthKitService: HealthKitServiceProtocol) {
        self.actions = actions
        self.healthKitService = healthKitService
        
        configureComposition()
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
    
    private func configureComposition() {
        var sections = [Section]()
        
        sections.append(configureIntensitySection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureIntensitySection() -> Section {
        let cells: [Cell] = [.intensity(IntensityCellViewModel())]
        
        return .section(.intensity,
                        title: nil,
                        cells: cells)
    }
}
