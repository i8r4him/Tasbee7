//
//  DhikrCard.swift
//  Tasbee7
//

import SwiftUI

struct DhikrCard: View {
    let dhikr: Dhikr
    let position: Int
    let total: Int
    let onCopy: () -> Void

    @Environment(ReadingPreferences.self) private var reading
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Pill(title: "\(position.formatted()) من \(total.formatted())", kind: .neutral)
                    .accessibilityHidden(true)
                Spacer()
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
