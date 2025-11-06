//
//  AthkarLoader.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation

enum AthkarLoaderError: Error, LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "لم يتم العثور على ملف البيانات hisn_almuslim.json في الحزمة"
        }
    }
}

struct AthkarLoader {
    func load() throws -> [AthkarSection] {
        guard let url = Bundle.main.url(forResource: "hisn_almuslim", withExtension: "json") else {
            throw AthkarLoaderError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([String: SectionContent].self, from: data)

        // Map to array (sorted by title for stable UI)
        return decoded
            .map { key, value in
                AthkarSection(title: key,
                               text: value.text,
                               footnote: value.footnote ?? [])
            }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
}


#if DEBUG
import SwiftUI

private struct AthkarLoaderPreviewView: View {
    @State private var sections: [AthkarSection] = []
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if let error {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if sections.isEmpty {
                    ProgressView("جاري التحميل…")
                } else {
                    List(sections.prefix(5)) { section in
                        Text(section.title)
                    }
                }
            }
            .navigationTitle("معاينة التحميل")
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let loaded = try AthkarLoader().load()
            await MainActor.run { self.sections = loaded }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }
}

#Preview {
    AthkarLoaderPreviewView()
}
#endif


