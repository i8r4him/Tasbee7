//
//  SectionGrid.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI

struct SectionGrid<Item: Identifiable, Content: View>: View {
    let title: String
    let systemImage: String
    let items: [Item]
    let content: (Item) -> Content

    private let columns = [
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(.title3.weight(.semibold))
            } icon: {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
            }
            .tint(.accentColor)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 12, pinnedViews: []) {
                ForEach(items) { item in
                    content(item)
                }
            }
        }
    }
}


