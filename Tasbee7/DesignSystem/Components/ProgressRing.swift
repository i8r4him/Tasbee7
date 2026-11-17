//
//  ProgressRing.swift
//  Tasbee7
//
//  A thick round line that brightens from the theme's deep tone to its full light as it goes round.
//

import SwiftUI

struct ProgressRing: View {
    /// 0...1
    let fraction: Double
    var lineWidth: CGFloat = 4

    var body: some View {
        let done = max(0, min(fraction, 1))
        ZStack {
            Circle()
                .stroke(Color.accentFill.opacity(0.22), lineWidth: lineWidth)

            if done > 0 {
                Circle()
                    .trim(from: 0, to: done)
                    .stroke(
                        AngularGradient(
                            colors: [Theme.shared.palette.deep, .accentFill],
                            center: .center,
                            startAngle: .zero,
                            endAngle: .degrees(360 * done)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            } else {
                Circle()
                    .fill(Theme.shared.palette.deep)
                    .frame(width: lineWidth, height: lineWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .offset(y: -lineWidth / 2)
            }
        }
        .padding(lineWidth / 2)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 24) {
        ProgressRing(fraction: 0, lineWidth: 14).frame(width: 120, height: 120)
        ProgressRing(fraction: 0.62, lineWidth: 14).frame(width: 120, height: 120)
    }
    .padding()
}
