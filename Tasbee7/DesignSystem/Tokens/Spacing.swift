//
//  Spacing.swift
//  Tasbee7
//

import SwiftUI

enum Spacing {
    /// Side padding of a screen.
    static let screen: CGFloat = 16
    /// Side padding of onboarding.
    static let onboarding: CGFloat = 20
    /// Padding inside a card or row.
    static let card: CGFloat = 16
    /// Padding inside hero cards.
    static let cardLarge: CGFloat = 22
    /// Gap between cards.
    static let grid: CGFloat = 12
    /// Gap between sections.
    static let section: CGFloat = 30
    static let rowMinHeight: CGFloat = 50
    static let minTouchTarget: CGFloat = 44
    /// Widest content on a wide screen.
    static let readableWidth: CGFloat = 720
    /// Widest focused flows (onboarding).
    static let focusedWidth: CGFloat = 600
}

/// Always used with `style: .continuous`.
enum Radius {
    static let hero: CGFloat = 38
    static let card: CGFloat = 38
    static let innerCard: CGFloat = 38
    static let option: CGFloat = 18
    static let tile: CGFloat = 16
}

extension Shape where Self == RoundedRectangle {
    /// The card shape: radius 38, continuous corners.
    static var card: RoundedRectangle { RoundedRectangle(cornerRadius: Radius.card, style: .continuous) }
}
