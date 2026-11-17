//
//  Chips.swift
//  Tasbee7
//
//  Pills, filter chips and symbol squares.
//

import SwiftUI

/// A small capsule label ("12 باباً", "جديد").
struct Pill: View {
    enum Kind { case accent, neutral, success }

    let title: String
    var kind: Kind = .accent

    var body: some View {
        Text(title)
            .textRole(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background, in: .capsule)
    }

    private var foreground: Color {
        switch kind {
        case .accent: .accent
        case .neutral: .secondary
        case .success: .success
        }
    }

    private var background: Color {
        switch kind {
        case .accent: .accentFill.opacity(0.18)
        case .neutral: .controlFill
        case .success: .success.opacity(0.16)
        }
    }
}

/// A `controlFill` capsule, inverted when selected. 44 pt tap area, `.selection` haptic.
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            action()
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .foregroundStyle(isSelected ? Color.screenBackground : Color.primary)
                .padding(.horizontal, 14)
                .frame(minHeight: 32)
                .background(isSelected ? Color.primary : Color.controlFill, in: .capsule)
                .padding(.vertical, 6)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: taps)
    }
}

/// A symbol on a small rounded square, for settings rows.
struct SymbolSquare: View {
    let systemImage: String
    var tint: Color = .controlFill
    var foreground: Color = .primary
    var size: CGFloat = 30

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(tint, in: .rect(cornerRadius: size * 0.27, style: .continuous))
            .accessibilityHidden(true)
    }
}
