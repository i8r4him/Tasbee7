//
//  SkyBackground.swift
//  Tasbee7
//
//  A warm night sky: a soft glow of the theme colour from the top and a few faint stars that twinkle.
//  Main tab screens use it; pushed screens and sheets use `.screenBackground`.
//

import SwiftUI

extension View {
    /// A warm glow in the theme colour from the top, with faint twinkling stars.
    func skyBackground() -> some View {
        background {
            ZStack {
                RadialGradient(
                    colors: [.accentFill.opacity(0.22), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 420
                )
                StarSky()
            }
            .ignoresSafeArea()
            .background(Color.screenBackground.ignoresSafeArea())
        }
    }

    /// The plain background for pushed screens and sheets.
    func plainBackground() -> some View {
        background(Color.screenBackground.ignoresSafeArea())
    }
}

/// Faint stars in the top third of the screen. Seeded, so they never jump between launches.
private struct StarSky: View {
    @Environment(\.reducesMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isVisible = false

    private static let stars: [Star] = {
        var generator = SeededGenerator(seed: 0x7A5BEE7)
        return (0..<14).map { _ in Star(using: &generator) }
    }()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion || !isVisible)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                drawHaze(in: &context, size: size, time: time)
                drawStars(in: &context, size: size, time: time)
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var starColor: Color {
        colorScheme == .dark ? .white : Theme.shared.palette.deep
    }

    private func drawHaze(in context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let breathing = reduceMotion ? 1 : 1 + 0.04 * sin(time * 2 * .pi / 16)
        let radius = size.width * 0.72 * breathing
        let centre = CGPoint(x: size.width / 2, y: -radius * 0.35)
        context.fill(
            Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [Color.accentFill.opacity(0.14), .clear]),
                center: centre,
                startRadius: 0,
                endRadius: radius
            )
        )

        let smallRadius = size.width * 0.4
        let smallCentre = CGPoint(x: size.width * 0.9, y: size.height * 0.04)
        context.fill(
            Path(ellipseIn: CGRect(x: smallCentre.x - smallRadius, y: smallCentre.y - smallRadius,
                                   width: smallRadius * 2, height: smallRadius * 2)),
            with: .radialGradient(
                Gradient(colors: [Color.accentFill.opacity(0.045), .clear]),
                center: smallCentre,
                startRadius: 0,
                endRadius: smallRadius
            )
        )
    }

    private func drawStars(in context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let band = size.height * 0.3
        for star in Self.stars {
            let twinkle = reduceMotion ? 1 : 0.6 + 0.4 * sin(time * star.speed + star.phase)
            let sway = reduceMotion ? 0 : sin(time * star.speed * 0.3 + star.phase) * star.sway
            let y = star.y * band
            let fade = 1 - (y / band) * 0.7
            let point = CGPoint(x: star.x * size.width + sway, y: y)
            let rect = CGRect(x: point.x - star.radius, y: point.y - star.radius,
                              width: star.radius * 2, height: star.radius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(starColor.opacity(star.opacity * twinkle * fade)))
        }
    }
}

private struct Star {
    let x: Double
    let y: Double
    let radius: Double
    let opacity: Double
    let speed: Double
    let phase: Double
    let sway: Double

    init(using generator: inout SeededGenerator) {
        x = Double.random(in: 0.04...0.96, using: &generator)
        y = Double.random(in: 0.02...1, using: &generator)
        radius = Double.random(in: 1...2.2, using: &generator)
        opacity = Double.random(in: 0.06...0.17, using: &generator)
        speed = Double.random(in: 0.5...1.1, using: &generator)
        phase = Double.random(in: 0...(2 * .pi), using: &generator)
        sway = Double.random(in: 3...6, using: &generator)
    }
}

/// A small deterministic generator (SplitMix64).
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
