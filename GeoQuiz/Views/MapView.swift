//
//  MapView.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 30.12.21.
//
import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel:GameViewModel
    
    var places:[GeoPlace]

    
    var body: some View {
        Map(coordinateRegion: self.$viewModel.regionMap, showsUserLocation: true, annotationItems: places) { location in
            MapAnnotation(coordinate: location.coordinate) {
                PlaceAnnotationView(place: location,
                                    color: colorPicker(geoState:location.state)) { place in
                    // if inGame
                    if (location.state == .guessing || !viewModel.inGame) {
                        viewModel.answerClicked(answer: location)

                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.fetchRegion()
            MKMapView.appearance().showsPointsOfInterest = false
        }
    }
    
    func colorPicker(geoState:GeoPlace.GeoState) -> Color {
        var color:Color = Color.pink
        if (viewModel.gameState == .inGame) {
            if(geoState == .guessing) {
                color = Color.black
            } else {
                color = Color.blue
            }
        } else if (viewModel.gameState == .gameOver) {
            if(geoState == .correct) {
                color = Color.green
            } else {
                color = Color.red
            }
        }
        return color
    }
}

struct PlaceAnnotationView: View {
    let place: GeoPlace;
    let color: Color;
    let onPlaceClicked: ((_ place: GeoPlace) -> Void)
        var body: some View {
            VStack(spacing: 0) {
                Text (place.title!)
                    .font(.callout)
                    .padding (5)
                    .background (Color(.white))
                    .cornerRadius(10)
                    .opacity(place.show ? 1 : 0)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(color)
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font (.caption)
                    .foregroundColor(color)
                    .offset (x: 0, y: -5)
            }
            .onTapGesture{
                onPlaceClicked(place)
            }
            
        }
    
}
    
