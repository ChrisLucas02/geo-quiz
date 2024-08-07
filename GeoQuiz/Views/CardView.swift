//
//  CardView.swift
//  Memory
//
//  Created by Chris Lucas on 10.12.20.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .shadow(radius: 3)
            self.content()
        }
    }
    
    init (@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView() {
            VStack {
                Text("Title") .font(.largeTitle)
                Text("Description")
            }
        }
    }
}
