//
//  DhikrCard.swift
//  Tasbee7
//

import SwiftUI

struct DhikrCard: View {
    let dhikr: Dhikr
    let position: Int
    let total: Int
    /// nil when the chapter isn't a daily sitting, so there is nothing to tick.
    var isDone: Bool?
    var onToggle: () -> Void = {}
    let onCopy: () -> Void

    @Environment(ReadingPreferences.self) private var reading
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Pill(title: "\(position.formatted()) من \(total.formatted())", kind: isDone == true ? .accent : .neutral)
                    .accessibilityHidden(true)
                Spacer()
                if let isDone {
                    TickButton(isDone: isDone, action: onToggle)
                }
                Menu {
                    Button(action: onCopy) {
                        Label("نسخ", systemImage: "doc.on.doc")
                    }
                    ShareLink(item: shareText) {
                        Label("مشاركة", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: Spacing.minTouchTarget, height: 30)
                        .contentShape(.rect)
                }
                .accessibilityLabel("خيارات الذكر")
            }

            Text(dhikr.text)
                .font(reading.font.font(size: reading.size.baseSize * scale))
                .lineSpacing(reading.font.lineSpacing * scale)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

            if let source = dhikr.source {
                Text(source)
                    .textRole(.meta)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }

    private var shareText: String {
        if let source = dhikr.source {
            return "\(dhikr.text)\n\n\(source)"
        }
        return dhikr.text
    }
}

/// A glass circle that ticks a dhikr as read. 36 pt visible, 44 pt to tap.
private struct TickButton: View {
    let isDone: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isDone ? "checkmark" : "circle")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isDone ? Color.onAccent : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 36, height: 36)
                .background {
                    if isDone {
                        Circle().fill(Color.accentFill)
                    }
                }
                .glassEffect(.regular.interactive(), in: .circle)
                .frame(width: Spacing.minTouchTarget, height: Spacing.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isDone)
        .accessibilityLabel(isDone ? "مقروء، اضغط لإلغاء التحديد" : "تحديد كمقروء")
        .accessibilityAddTraits(isDone ? .isSelected : [])
    }
}
