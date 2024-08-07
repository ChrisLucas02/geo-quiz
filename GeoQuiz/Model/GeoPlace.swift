//
//  GeoPlace.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 13.12.20.
//

import Foundation
import MapKit
import Combine

class GeoPlace : MKPointAnnotation, Identifiable, ObservableObject {
    
    var id = UUID()
    
    @Published var state: GeoState = .guessing
    
    enum GeoState {
        case guessing, answered, correct, incorrect
    }

    @Published var show: Bool = false;
    
}
