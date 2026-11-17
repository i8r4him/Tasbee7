//
//  ScrollStyle.swift
//  Tasbee7
//
//  Every scroll view: soft edges, no scroll bars. Main scroll views also keep a readable width.
//

import SwiftUI

extension View {
    /// Soft scroll edges and hidden indicators. Put it right after every scroll view.
    func softScroll() -> some View {
        self
            .scrollIndicators(.hidden)
            .scrollEdgeEffectStyle(.soft, for: .all)
    }

    /// For a ScrollView: centres the content at a readable width on wide screens.
    func readableContentMargins(_ limit: CGFloat = Spacing.readableWidth) -> some View {
        modifier(ReadableContentMargins(limit: limit))
    }

    /// For content that doesn't scroll.
    func readableWidth(_ limit: CGFloat = Spacing.readableWidth) -> some View {
        frame(maxWidth: limit).frame(maxWidth: .infinity)
    }
}

private struct ReadableContentMargins: ViewModifier {
    let limit: CGFloat
    @State private var width: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .contentMargins(.horizontal, max(0, (width - limit) / 2).rounded(.down), for: .scrollContent)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { newWidth in
                width = newWidth
            }
    }
}
