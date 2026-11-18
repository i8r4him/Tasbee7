//
//  Buttons.swift
//  Tasbee7
//
//  The big button (main call to action), pressable cards and glass circle buttons.
//

import SwiftUI

// MARK: - The big button

/// A full-width glass capsule with two soft lights in the theme colour rising from its bottom edge.
/// Every large call to action uses it.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        BigButtonBody(configuration: configuration)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

private struct BigButtonBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    private var palette: ThemePalette { Theme.shared.palette }

    /// White on dark glass; the theme's deep tone on light glass.
    private var labelColour: Color { colorScheme == .dark ? .white : palette.deep }
    private var honey: Color { palette == .gold ? Color(hex: 0xFFCC7A) : palette.mid }
    private var orange: Color { palette == .gold ? Color(hex: 0xF28C38) : palette.rim }

    var body: some View {
        configuration.label
            .font(.title3.weight(.bold))
            .fontDesign(.rounded)
            .foregroundStyle(labelColour.opacity(isEnabled ? 1 : 0.45))
            .frame(maxWidth: .infinity, minHeight: 34)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    BottomLight(color: honey, x: 0.3)
                    BottomLight(color: orange, x: 0.78)
                }
                .clipShape(.capsule)
                .overlay {
                    Capsule().strokeBorder(
                        LinearGradient(colors: [.white.opacity(0.18), .clear], startPoint: .top, endPoint: .center),
                        lineWidth: 1
                    )
                    Capsule().strokeBorder(
                        LinearGradient(
                            colors: [.clear, honey.opacity(0.7), orange.opacity(0.8), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
                    .mask {
                        LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
                    }
                }
                .opacity(isEnabled ? 1 : 0.25)
            }
            .glassEffect(isEnabled ? .regular.interactive() : .regular, in: .capsule)
            .contentShape(.capsule)
            .sensoryFeedback(.impact(weight: .medium), trigger: configuration.isPressed) { _, pressed in pressed }
    }
}

/// A soft light centred just below the bottom edge, fading upwards.
private struct BottomLight: View {
    let color: Color
    let x: CGFloat

    var body: some View {
        RadialGradient(
            colors: [color.opacity(0.55), color.opacity(0.18), .clear],
            center: UnitPoint(x: x, y: 1.1),
            startRadius: 0,
            endRadius: 140
        )
    }
}

// MARK: - Pressable cards

/// Any card used as a button label: scales a little when pressed.
struct PressableCardStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.98

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(Motion.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableCardStyle {
    static var card: PressableCardStyle { PressableCardStyle() }
    static var tile: PressableCardStyle { PressableCardStyle(pressedScale: 0.96) }
}

// MARK: - Glass circle

/// An icon-only glass circle: 36 pt visible, 44 pt tap area, always labelled.
struct GlassButton: View {
    let systemImage: String
    let accessibilityLabel: LocalizedStringKey
    var diameter: CGFloat = 36
    var foreground: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: diameter * 0.42, weight: .semibold))
                .foregroundStyle(foreground)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: diameter, height: diameter)
                .glassEffect(.regular.interactive(), in: .circle)
                .frame(minWidth: Spacing.minTouchTarget, minHeight: Spacing.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
