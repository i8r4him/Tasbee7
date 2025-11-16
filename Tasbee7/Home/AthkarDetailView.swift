//
//  AthkarDetailView.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI

enum FontSize: String, CaseIterable, Identifiable {
    case small = "صغير"
    case medium = "متوسط"
    case large = "كبير"
    case extraLarge = "كبير جداً"
    
    var id: String { rawValue }
    
    var size: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 20
        case .extraLarge: return 24
        }
    }
    
    var displayName: String { rawValue }
}

struct AthkarDetailView: View {
    let title: String
    let textItems: [String]
    let footnotes: [String]
    @Environment(FavoritesStore.self) private var favorites
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    @AppStorage(AppTheme.fontStorageKey) private var fontRaw: String = AthkarFont.system.rawValue
    @AppStorage("athkarFontSize") private var fontSizeRaw: String = FontSize.medium.rawValue
    
    private var selectedFont: AthkarFont {
        AthkarFont(rawValue: fontRaw) ?? .system
    }
    
    private var selectedFontSize: FontSize {
        FontSize(rawValue: fontSizeRaw) ?? .medium
    }
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    private var customFontWithSize: Font {
        switch selectedFont {
        case .system:
            return .system(size: selectedFontSize.size, design: .default)
        case .scheherazade:
            // Try to get the custom font with the selected size
            let possibleNames = [
                "ScheherazadeNew-Regular",
                "ScheherazadeNew",
                "Scheherazade New",
                "ScheherazadeNewRegular"
            ]
            
            for fontName in possibleNames {
                if let uiFont = UIFont(name: fontName, size: selectedFontSize.size) {
                    return Font(uiFont)
                }
            }
            
            // If font not found, try by family name
            let familyNames = ["Scheherazade New", "ScheherazadeNew", "Scheherazade"]
            for familyName in familyNames {
                let familyFonts = UIFont.fontNames(forFamilyName: familyName)
                if !familyFonts.isEmpty, let firstFont = familyFonts.first {
                    if let uiFont = UIFont(name: firstFont, size: selectedFontSize.size) {
                        return Font(uiFont)
                    }
                }
            }
            
            // Fallback to system serif with selected size
            return .system(size: selectedFontSize.size, design: .serif)
        }
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
                                    .foregroundStyle((ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Box with text and footnote
                        VStack(alignment: .leading, spacing: 0) {
                            // Text content
                            Text(textItems[index])
                                .font(customFontWithSize)
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
            .padding()
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
                    Section("حجم الخط") {
                        ForEach(FontSize.allCases) { size in
                            Button {
                                fontSizeRaw = size.rawValue
                            } label: {
                                HStack {
                                    Text(size.displayName)
                                    if selectedFontSize.id == size.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("نوع الخط") {
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
                    }
                } label: {
                    Image(systemName: "textformat.size")
                }
                .accessibilityLabel(Text("إعدادات الخط"))
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


