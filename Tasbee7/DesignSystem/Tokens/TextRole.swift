//
//  TextRole.swift
//  Tasbee7
//
//  Named text sizes that keep their size at the default text size and scale with Dynamic Type.
//

import SwiftUI

enum TextRole {
    case hero, largeTitle, title2, sectionHeader, cardTitle, body, bodySmall, meta, caption, eyebrow

    var size: CGFloat {
        switch self {
        case .hero: 44
        case .largeTitle: 34
        case .title2: 28
        case .sectionHeader: 22
        case .cardTitle, .body: 17
        case .bodySmall: 15
        case .meta, .eyebrow: 13
        case .caption: 12
        }
    }

    var weight: Font.Weight {
        switch self {
        case .hero, .largeTitle, .title2, .sectionHeader: .bold
        case .cardTitle, .eyebrow: .semibold
        default: .regular
        }
    }

    var tracking: CGFloat {
        switch self {
        case .hero: -1.4
        case .largeTitle: -0.9
        case .title2: -0.8
        case .sectionHeader: -0.4
        case .eyebrow: 0.07 * size
        default: 0
        }
    }

    var textStyle: Font.TextStyle {
        switch self {
        case .hero, .largeTitle: .largeTitle
        case .title2: .title
        case .sectionHeader: .title2
        case .body: .body
        case .cardTitle: .headline
        case .bodySmall: .subheadline
        case .meta, .eyebrow: .footnote
        case .caption: .caption
        }
    }
}

private struct TextRoleModifier: ViewModifier {
    let role: TextRole
    @ScaledMetric private var size: CGFloat

    init(role: TextRole) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.size, relativeTo: role.textStyle)
    }

    @ViewBuilder func body(content: Content) -> some View {
        let styled = content
            .font(.system(size: size, weight: role.weight))
            .tracking(role.tracking * size / role.size)
        if role == .eyebrow {
            styled.textCase(.uppercase)
        } else {
            styled
        }
    }
}

extension View {
    func textRole(_ role: TextRole) -> some View {
        modifier(TextRoleModifier(role: role))
    }
}
