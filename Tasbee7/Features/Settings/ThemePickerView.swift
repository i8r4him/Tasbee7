//
//  ThemePickerView.swift
//  Tasbee7
//
//  Pick the one colour the whole app is lit by.
//

import SwiftUI

struct ThemePickerView: View {
    @Bindable private var theme = Theme.shared

    private let columns = [GridItem(.adaptive(minimum: 92), spacing: Spacing.grid)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                preview

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(ThemePalette.allCases) { palette in
                        Swatch(palette: palette, isSelected: theme.palette == palette) {
                            withAnimation(Motion.easeOut(duration: 0.3)) {
                                theme.palette = palette
                            }
                        }
                    }
                }
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .skyBackground()
        .navigationTitle("لون التطبيق")
        .toolbarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: theme.palette)
    }

    /// A small card that shows the theme on the things it colours.
    private var preview: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(theme.palette.name)
                    .font(.title3.weight(.semibold))
                Text("يتغيّر به التطبيق كله.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Pill(title: "مثال")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ProgressRing(fraction: 0.66, lineWidth: 8)
                .frame(width: 64, height: 64)
            Artwork(systemImage: "moon.stars.fill", symbolSize: 34, cornerRadius: 18)
                .frame(width: 72, height: 72)
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }
}

private struct Swatch: View {
    let palette: ThemePalette
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [palette.accentFill, palette.deep], startPoint: .topLeading, endPoint: .bottomTrailing))
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(palette.onAccent)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 60, height: 60)
                .padding(4)
                .overlay {
                    Circle().strokeBorder(isSelected ? palette.accentFill.opacity(0.55) : .clear, lineWidth: 2)
                }

                Text(palette.name)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(minWidth: Spacing.minTouchTarget, minHeight: Spacing.minTouchTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.tile)
        .accessibilityLabel(palette.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack { ThemePickerView() }
}
