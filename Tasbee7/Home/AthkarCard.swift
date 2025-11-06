//
//  AthkarCard.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI

struct AthkarCard: View, Equatable {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(20)
        .glassEffect(.regular.interactive(true), in: RoundedRectangle(cornerRadius: 20))
        .tint(.accentColor)
    }
}

#Preview {
    AthkarCard(title: "فضل الذكر")
        .padding()
}


