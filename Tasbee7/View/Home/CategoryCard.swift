//
//  CategoryCard.swift
//  Tasbee7
//
//  Created by Codex on 09.02.26.
//

import SwiftUI

struct CategoryCard: View {
    let title: String
    let systemImage: String
    let count: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(count) موضوع")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .padding(16)
        .glassEffect(.regular.interactive(true), in: RoundedRectangle(cornerRadius: 20))
        .tint(.accentColor)
    }
}

#Preview {
    CategoryCard(title: "الصباح والمساء", systemImage: "sun.horizon.fill", count: 12)
        .padding()
}
