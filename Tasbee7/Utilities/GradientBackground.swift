//
//  GradientBackground.swift
//  Uni
//
//  Created by Ibrahim Abdullah on 18.09.25.
//

import SwiftUI

struct GradientBackground: View {
    
    var startColor: Color
    var endColor: Color
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [startColor, endColor, .clear]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ZStack {
        GradientBackground(
            startColor: .blue.opacity(0.3),
            endColor: .clear
        )
        Text("Content goes here")
    }
}
