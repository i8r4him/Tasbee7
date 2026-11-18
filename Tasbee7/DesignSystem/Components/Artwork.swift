//
//  Artwork.swift
//  Tasbee7
//
//  Illustrations are not images: a large thin SF Symbol, tilted, on the theme gradient.
//

import SwiftUI

struct Artwork: View {
    let systemImage: String
    var symbolSize: CGFloat = 52
    var cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentFill.opacity(0.95), Theme.shared.palette.deep.opacity(0.8)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            RadialGradient(
                colors: [.white.opacity(0.35), .clear],
                center: UnitPoint(x: 0.25, y: 0.2),
                startRadius: 0,
                endRadius: 60
            )
            Image(systemName: systemImage)
                .font(.system(size: symbolSize, weight: .light))
                .foregroundStyle(.white.opacity(0.85))
                .rotationEffect(.degrees(-12))
                .offset(x: symbolSize * 0.15, y: symbolSize * 0.12)
        }
        .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
        .mask {
            LinearGradient(
                stops: [.init(color: .black, location: 0.55), .init(color: .clear, location: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        Artwork(systemImage: "sun.horizon.fill").frame(width: 96, height: 96)
        Artwork(systemImage: "moon.stars.fill", symbolSize: 34, cornerRadius: 16).frame(width: 64, height: 64)
    }
    .padding()
}
