//
//  ScreenLoading.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 28/09/25.
//

import SwiftUI

struct ScreenLoading: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 1, green: 1, blue: 1),
                Color(red: 0.0, green: 0.71, blue: 0.737)]),
                           startPoint: UnitPoint(x:0.5, y:0.7),
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                // Logo
                Image("FRAUD FISHING-03")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 500, height: 360)
                    .padding(.bottom, 100)
            }
        }
        
    }
}

#Preview {
    ScreenLoading()
}
