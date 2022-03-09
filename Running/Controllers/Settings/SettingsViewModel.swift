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
        case importWorkouts
    }
    
    enum Cell {
        
    }
    
    // MARK: - Private methods
    
    private func configureComposition() {
        var sections = [Section]()
        
        sections.append(configureImportWorkoutsSection())
        
        compositionSubject.onNext(Composition(sections: sections))
    }
    
    private func configureImportWorkoutsSection() -> Section {
        let cells: [Cell] = []
        
        return .section(.importWorkouts,
                        title: nil,
                        cells: cells)
    }
}
