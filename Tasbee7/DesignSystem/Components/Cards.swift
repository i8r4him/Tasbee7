//
//  Cards.swift
//  Tasbee7
//
//  Section headers, state cards (empty, error), and the toast.
//

import SwiftUI

/// A section title, optionally a button that opens "see all".
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) {
                label(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else {
            label(showsChevron: false)
        }
    }

    private func label(showsChevron: Bool) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .textRole(.sectionHeader)
                .foregroundStyle(.primary)
            if showsChevron {
                Image(systemName: "chevron.forward")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

/// Every state that isn't the answer: what happened on one side, artwork on the other,
/// and a glass button under it only when there is something to do.
struct StateCard: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var actionSystemImage: String = "arrow.clockwise"
    var action: (() -> Void)?

    @ScaledMetric(relativeTo: .title) private var artworkSize: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)

                Artwork(systemImage: systemImage, symbolSize: 34, cornerRadius: 18)
                    .frame(width: artworkSize, height: artworkSize)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: actionSystemImage)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }
}

/// A glass capsule at the bottom with a green check. Announced to VoiceOver, plays `.success`, leaves after 2 s.
struct Toast: View {
    let message: String

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.success)
        }
        .textRole(.bodySmall)
        .fontWeight(.medium)
        .padding(.horizontal, 18)
        .frame(minHeight: Spacing.minTouchTarget)
        .glassEffect(.regular, in: .capsule)
    }
}

extension View {
    /// Shows a toast above the tab bar while `message` is non-nil, then clears it after 2 s.
    func toast(_ message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var message: String?
    @Environment(\.reducesMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    Toast(message: message)
                        .padding(.bottom, 96)
                        .transition(Motion.modalTransition(reduceMotion: reduceMotion))
                        .task(id: message) {
                            AccessibilityNotification.Announcement(message).post()
                            try? await Task.sleep(for: .seconds(2))
                            guard !Task.isCancelled else { return }
                            withAnimation(Motion.modal(reduceMotion: reduceMotion)) {
                                self.message = nil
                            }
                        }
                }
            }
            .animation(Motion.modal(reduceMotion: reduceMotion), value: message)
            .sensoryFeedback(.success, trigger: message) { _, new in new != nil }
    }
}
