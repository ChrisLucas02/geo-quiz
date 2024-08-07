//
//  HomeViewModel.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 12.12.20.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    static let minNumberOfPlaces = 5
    static let minRadius = 100
    
    // Input
    @Published var numberOfPlaces = ""
    @Published var radius = ""
    
    // Output
    @Published private(set) var isValid = false
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init() {
        isDataValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)
    }
    
    private var isNumberOfPlacesValidPublisher: AnyPublisher<Bool, Never> {
        $numberOfPlaces
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                guard let value = Int(input) else { return false }
                return value >= HomeViewModel.minNumberOfPlaces
        }
        .eraseToAnyPublisher()
    }
    
    private var isRadiusValidPublisher: AnyPublisher<Bool, Never> {
        $radius
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                guard let value = Int(input) else { return false }
                return value >= HomeViewModel.minRadius
        }
        .eraseToAnyPublisher()
    }
    
    private var isDataValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isNumberOfPlacesValidPublisher, isRadiusValidPublisher)
            .map { isNumberOfPlacesValid, isRadiusValid in
                isNumberOfPlacesValid && isRadiusValid
        }
        .eraseToAnyPublisher()
    }
}
