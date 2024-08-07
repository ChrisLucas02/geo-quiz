//
//  HomeView.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 12.12.20.
//

import SwiftUI
import MapKit

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    private let isUIKit: Bool;
    
    init(radius: Int, numberOfPlaces: Int, isUIKit: Bool) {
        viewModel = GameViewModel(radius: radius, numberOfPlaces: numberOfPlaces)
        self.isUIKit = isUIKit;
    }
    
    var body: some View {
        ZStack {
            if isUIKit {
                UIKitMapVIew
            }else {
                mapView
            }
            
            gameOverlay
        }.environmentObject(viewModel)
        .navigationBarTitle(Text(self.viewModel.infoText), displayMode: .inline)
        .onAppear() {
            self.viewModel.startFetchPlaces()
        }
    }
    
    
    var UIKitMapVIew: some View {
        UIKitMapView(isEdit: self.$viewModel.inGame, places: self.viewModel.places, onPlaceClicked: { place in
            self.viewModel.answerClicked(answer: place)
        })
        .edgesIgnoringSafeArea(.all)
    }
    
    var mapView: some View{
        MapView(viewModel: self.viewModel, places: self.viewModel.places)
    }
    
    var gameOverlay: some View {
        VStack {
            question
            Spacer()
            caption
        }
    }
    
    var question: some View {
        CardView() {
            VStack {
                Text(self.viewModel.placeText)
                    .font(.title2)
                    .lineLimit(1)
                    .padding()
            }
        }
        .frame(height: 50)
        .padding()
    }
    
    var caption: some View {
        HStack {
            switch viewModel.gameState {
            case .inGame:
                CardView() {
                    HStack {
                        Circle().fill(Color.black).frame(width: 10, height: 10)
                        Text("Unanswered").font(.footnote)
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Text("Answered").font(.footnote)
                    }
                }
            case .gameOver:
                CardView() {
                    HStack {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Correct").font(.footnote)
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                        Text("Wrong").font(.footnote)
                    }
                }
            default:
                EmptyView()
            }
        }
        .frame(height: 30)
        .padding()
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(radius: 500, numberOfPlaces: 5, isUIKit: true)
    }
}
