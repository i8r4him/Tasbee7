//
//  ReaderFontMenu.swift
//  Tasbee7
//

import SwiftUI

/// The toolbar menu for the reading font and size.
struct ReaderFontMenu: View {
    @Environment(ReadingPreferences.self) private var reading

    var body: some View {
        @Bindable var reading = reading
        Menu {
            Section("حجم الخط") {
                Picker("حجم الخط", selection: $reading.size) {
                    ForEach(AthkarFontSize.allCases) { size in
                        Text(size.name).tag(size)
                    }
                }
                .pickerStyle(.inline)
            }
            Section("نوع الخط") {
                Picker("نوع الخط", selection: $reading.font) {
                    ForEach(AthkarFont.allCases) { font in
                        Text(font.name).tag(font)
                    }
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label("الخط", systemImage: "textformat.size")
        }
        .sensoryFeedback(.selection, trigger: reading.size)
        .sensoryFeedback(.selection, trigger: reading.font)
    }
}
