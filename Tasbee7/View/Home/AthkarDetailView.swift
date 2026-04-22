//
//  AthkarDetailView.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI
import UIKit

enum FontSize: String, CaseIterable, Identifiable {
    case small = "صغير"
    case medium = "متوسط"
    case large = "كبير"
    case extraLarge = "كبير جداً"

    var id: String { rawValue }

    var size: CGFloat {
        switch self {
        case .small: 16
        case .medium: 18
        case .large: 20
        case .extraLarge: 24
        }
    }

    var displayName: String { rawValue }
}

struct AthkarDetailView: View {
    let title: String
    let textItems: [String]
    let footnotes: [String]

    @Environment(FavoritesStore.self) private var favorites
    @Environment(AppSettings.self) private var appSettings

    @AppStorage(AppTheme.fontStorageKey) private var fontRaw: String = AthkarFont.system.rawValue
    @AppStorage("athkarFontSize") private var fontSizeRaw: String = FontSize.medium.rawValue

    private var selectedFont: AthkarFont {
        AthkarFont(rawValue: fontRaw) ?? .system
    }

    private var selectedFontSize: FontSize {
        FontSize(rawValue: fontSizeRaw) ?? .medium
    }

    private var detailFont: Font {
        selectedFont.font(size: selectedFontSize.size)
    }

    private var items: [AthkarDetailItem] {
        textItems.indices.map { index in
            AthkarDetailItem(
                id: index,
                text: textItems[index],
                footnote: footnotes.indices.contains(index) ? footnotes[index] : nil
            )
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(items) { item in
                    AthkarDetailCard(
                        text: item.text,
                        footnote: item.footnote,
                        font: detailFont,
                        themeColor: appSettings.themeColor,
                        copyText: { copy(item.text) }
                    )
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .appGradientBackground()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                FontSettingsMenu(
                    selectedFont: selectedFont,
                    selectedFontSize: selectedFontSize,
                    setFont: setFont,
                    setFontSize: setFontSize
                )

                Button(action: toggleFavorite) {
                    Image(systemName: favorites.isFavorite(title: title) ? "star.fill" : "star")
                }
                .accessibilityLabel(Text("المفضلة"))
            }
        }
    }

    private func setFont(_ font: AthkarFont) {
        fontRaw = font.rawValue
        AthkarFont.setSelectedFont(font)
    }

    private func setFontSize(_ fontSize: FontSize) {
        fontSizeRaw = fontSize.rawValue
    }

    private func toggleFavorite() {
        favorites.toggle(title: title)
    }

    private func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}

private struct AthkarDetailItem: Identifiable {
    let id: Int
    let text: String
    let footnote: String?
}

private struct AthkarDetailCard: View {
    let text: String
    let footnote: String?
    let font: Font
    let themeColor: Color
    let copyText: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()

                Menu {
                    Button(action: copyText) {
                        Label("نسخ", systemImage: "doc.on.doc")
                    }

                    ShareLink(item: text) {
                        Label("مشاركة", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(themeColor)
                        .padding(8)
                }
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 0) {
                Text(text)
                    .font(font)
                    .padding()
                    .lineSpacing(10)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)

                if let footnote, !footnote.isEmpty {
                    Text(footnote)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
            }
            .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
        }
    }
}

private struct FontSettingsMenu: View {
    let selectedFont: AthkarFont
    let selectedFontSize: FontSize
    let setFont: (AthkarFont) -> Void
    let setFontSize: (FontSize) -> Void

    var body: some View {
        Menu {
            Section("حجم الخط") {
                ForEach(FontSize.allCases) { size in
                    Button {
                        setFontSize(size)
                    } label: {
                        HStack {
                            Text(size.displayName)
                            if selectedFontSize == size {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section("نوع الخط") {
                ForEach(AthkarFont.allCases) { font in
                    Button {
                        setFont(font)
                    } label: {
                        HStack {
                            Text(font.displayName)
                            if selectedFont == font {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "textformat.size")
        }
        .accessibilityLabel(Text("إعدادات الخط"))
    }
}

#Preview {
    NavigationStack {
        AthkarDetailView(
            title: "فضل الذكر",
            textItems: [
                "قال الله تعالى:{ فَاذْكُرُونِي أَذْكُرْكُمْ }",
                "وقال صلى الله عليه وسلم: مثل الذي يذكر ربه والذي لا يذكر ربه مثل الحي والميت"
            ],
            footnotes: [
                "سورة البقرة آية :152",
                "البخاري مع الفتح 11/208"
            ]
        )
        .environment(FavoritesStore())
        .environment(AppSettings())
    }
}
