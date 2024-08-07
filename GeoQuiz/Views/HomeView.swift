//
//  ContentView.swift
//  GeoQuiz
//
//  Created by Chris Lucas on 12.12.20.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State var showGame: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
                Image("GeoQuiz")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                VStack {
                    createTextField(placeholder: "Number of Places (min. 5)", systemName: "mappin.and.ellipse", numericKeyboard: false, binding: $viewModel.numberOfPlaces)
                        .padding(.horizontal)
                    createTextField(placeholder: "Radius (min. 100)", systemName: "scope", numericKeyboard: false, binding: $viewModel.radius)
                        .padding(.horizontal)
                }
                .padding()
                
                Spacer()
                
                HStack{
                    NavigationLink(destination: DeferView { GameView(radius: Int(self.viewModel.radius) ?? HomeViewModel.minRadius, numberOfPlaces: Int(self.viewModel.numberOfPlaces) ?? HomeViewModel.minNumberOfPlaces,
                    isUIKit: true)
                    }) {
                        Text("Play UIKit")
                    }
                    .disabled(!self.viewModel.isValid)
                    NavigationLink(destination: DeferView { GameView(radius: Int(self.viewModel.radius) ?? HomeViewModel.minRadius, numberOfPlaces: Int(self.viewModel.numberOfPlaces) ?? HomeViewModel.minNumberOfPlaces,
                    isUIKit: false)
                    }) {
                        Text("Play MapKit")
                    }
                    .disabled(!self.viewModel.isValid)
                }
                
                
            }
            .padding()
            .navigationTitle("GeoQuiz")
        }
    }
    
    private func createTextField(placeholder: String, systemName: String, numericKeyboard: Bool, binding: Binding<String>) -> some View {
        return HStack {
            Image(systemName: systemName)
            TextField(placeholder, text: binding)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.black.opacity(0.5)))
        .keyboardType(.numbersAndPunctuation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDevice("iPhone 13")
    }
}
