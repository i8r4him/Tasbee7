//
//  GradientBackgroundModifier.swift
//  Uni
//
//  Created by Ibrahim Abdullah on 18.09.25.
//

import SwiftUI

struct GradientBackgroundModifier: ViewModifier {
    let startColor: Color
    let endColor: Color
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .background {
                LinearGradient(
                    gradient: Gradient(colors: [startColor, endColor, .clear]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .ignoresSafeArea(.all)
            }
    }
}

// MARK: - View Extension
extension View {
    /// Applies a gradient background to the view
    /// - Parameters:
    ///   - startColor: The starting color of the gradient
    ///   - endColor: The ending color of the gradient  
    ///   - startPoint: The start point of the gradient (default: .top)
    ///   - endPoint: The end point of the gradient (default: .bottom)
    /// - Returns: A view with the gradient background applied
    func gradientBackground(
        startColor: Color,
        endColor: Color,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> some View {
        self.modifier(
            GradientBackgroundModifier(
                startColor: startColor,
                endColor: endColor,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }
    
    /// Applies a default blue gradient background to the view
    /// - Returns: A view with a blue gradient background
    func gradientBackground() -> some View {
        self.gradientBackground(
            startColor: AppTheme.selectedThemeColor.color.opacity(0.3),
            endColor: .clear
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Default Gradient")
            .padding()
            .gradientBackground()
        
        Text("Custom Gradient")
            .padding()
            .gradientBackground(
                startColor: .purple.opacity(0.4),
                endColor: .pink.opacity(0.2)
            )
        
        Text("Diagonal Gradient")
            .padding()
            .gradientBackground(
                startColor: .green.opacity(0.3),
                endColor: .blue.opacity(0.2),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
    .padding()
}
