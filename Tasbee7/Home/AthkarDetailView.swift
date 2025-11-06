//
//  AthkarDetailView.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI

struct AthkarDetailView: View {
    let title: String
    let textItems: [String]
    let footnotes: [String]
    @Environment(FavoritesStore.self) private var favorites
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    @AppStorage(AppTheme.fontStorageKey) private var fontRaw: String = AthkarFont.system.rawValue
    
    private var selectedFont: AthkarFont {
        AthkarFont(rawValue: fontRaw) ?? .system
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(textItems.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        // Menu button above the box
                        HStack {
                            Spacer()
                            Menu {
                                Button {
                                    UIPasteboard.general.string = textItems[index]
                                } label: {
                                    Label("نسخ", systemImage: "doc.on.doc")
                                }
                                
                                ShareLink(item: textItems[index]) {
                                    Label("مشاركة", systemImage: "square.and.arrow.up")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(.secondary)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Box with text and footnote
                        VStack(alignment: .leading, spacing: 0) {
                            // Text content
                            Text(textItems[index])
                                .font(selectedFont.font)
                                .padding()
                                .lineSpacing(10)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Footnote below text (if exists)
                            if index < footnotes.count && !footnotes[index].isEmpty {
                                Text(footnotes[index])
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
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground(
            startColor: (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color.opacity(0.3),
            endColor: .clear
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(AthkarFont.allCases) { font in
                        Button {
                            fontRaw = font.rawValue
                            AthkarFont.setSelectedFont(font)
                        } label: {
                            HStack {
                                Text(font.displayName)
                                if selectedFont.id == font.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "textformat")
                }
                .accessibilityLabel(Text("خط النص"))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favorites.toggle(title: title)
                } label: {
                    Image(systemName: favorites.isFavorite(title: title) ? "star.fill" : "star")
                }
                .accessibilityLabel(Text("المفضلة"))
            }
        }
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
    }
}


