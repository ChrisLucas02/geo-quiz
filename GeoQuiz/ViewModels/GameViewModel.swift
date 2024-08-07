//
//  GameViewModel.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 13.12.20.
//

import Foundation
import MapKit
import Combine
import SwiftUI

class GameViewModel : ObservableObject {
    public enum GameState {
        case idle, fetching, inGame, gameOver
    }
    
    // Output Publishers
    @Published private(set) var infoText = ""
    @Published private(set) var placeText = ""
    @Published private(set) var answers: [GeoPlace] = []
    @Published var places: [GeoPlace] = []
    @Published private(set) var gameState = GameState.idle
    @Published var inGame = false
    
    //TODO: publish MapRegion
    @Published var regionMap:MKCoordinateRegion = MKCoordinateRegion()
    
    // Config Parameters
    var numberOfPlaces: Int
    var radius: Int
    
    // Private Attributes
    private var score = 0
    private var position = 0
    private var locationManager = LocationManager()
    private var cancellableSet = Set<AnyCancellable>()
    
    init(radius: Int, numberOfPlaces: Int) {
        self.radius = radius
        self.numberOfPlaces = numberOfPlaces
    }
    
    //TODO: fetch Region
    func fetchRegion() {
        locationManager.regionPublisher
            .sink(receiveValue: { region in
                self.regionMap = region            })
            .store(in: &cancellableSet)
    }
    
    func startFetchPlaces () {
        gameState = .fetching
        
        locationManager.locationPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { coordinate in
                guard let coordinate = coordinate else { return }
                self.startGame(location: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            })
            .store(in: &cancellableSet)
        
        $gameState
            .map { state in
                state == .inGame
            }
            .assign(to: \.inGame, on: self)
            .store(in: &cancellableSet)
    }
    
    func answerClicked (answer: GeoPlace) {
        
        
        if gameState != .inGame || answers.contains(answer) {
           
            answer.show = !answer.show            
            objectWillChange.send()
            
            return
        }
        
        answer.state = .answered
        answers.append(answer)
        position += 1
        
        if position >= numberOfPlaces {
            inGame = false
            gameState = .gameOver
            score = calculateScore()
            
            infoText = "Game Over"
            placeText = "Correct Answers: \(score)/\(numberOfPlaces)"
        } else {
            infoText = "\(position)/\(numberOfPlaces) answered"
            placeText = places[position].title ?? "Not found"
        }
    }
    
    private func calculateScore () -> Int {
        var score = 0
        
        for i in 0 ..< numberOfPlaces {
            let answer = answers[i]
            let place = places[i]
            
            if answer.title == place.title {
                place.state = .correct
                answer.state = .correct
                score += 1
            } else {
                place.state = .incorrect
                answer.state = .incorrect
            }
        }
        
        return score
    }
    
    private func startGame (location: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        let request = MKLocalSearch.Request()
        let meters = CLLocationDistance(self.radius)
        request.naturalLanguageQuery = "Restaurants"
        request.region = MKCoordinateRegion(center: location, latitudinalMeters: meters, longitudinalMeters: meters)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            if response.mapItems.count < self.numberOfPlaces {
                return
            }
            
            var res = response.mapItems
            res.shuffle()
            
            for i in 0 ..< self.numberOfPlaces {
                let item = res[i]
                let place = GeoPlace()
                place.title = item.name!
                place.coordinate = item.placemark.location!.coordinate
                self.places.append(place)
            }
            
            self.position = 0
            self.gameState = GameState.inGame
            
            self.infoText = "\(self.position)/\(self.numberOfPlaces) answered"
            self.placeText = self.places[self.position].title!
            
            for cancellable in self.cancellableSet {
                cancellable.cancel()
            }
        }
    }
}
