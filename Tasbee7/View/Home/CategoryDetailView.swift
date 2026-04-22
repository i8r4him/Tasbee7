//
//  CategoryDetailView.swift
//  Tasbee7
//
//  Created by Codex on 09.02.26.
//

import SwiftUI

struct CategoryDetailView: View {
    let group: HomeSections.Group

    @Environment(AppSettings.self) private var appSettings

    private let columns = [
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(group.items) { item in
                    NavigationLink {
                        AthkarDetailView(
                            title: item.title,
                            textItems: item.text,
                            footnotes: item.footnote
                        )
                    } label: {
                        AthkarCard(title: item.title)
                            .equatable()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(group.title)
        .navigationBarTitleDisplayMode(.inline)
        .appGradientBackground()
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(
            group: .init(
                id: "الصباح والمساء",
                title: "الصباح والمساء",
                items: [
                    AthkarSection(title: "أذكار الصباح والمساء", text: ["..."], footnote: [])
                ]
            )
        )
    }
    .environment(AppSettings())
}
