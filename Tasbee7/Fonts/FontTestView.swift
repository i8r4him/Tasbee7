//
//  FontTestView.swift
//  Tasbee7
//
//  Temporary view to test and find font names
//

import SwiftUI

struct FontTestView: View {
    @State private var availableFonts: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("Available Fonts in Bundle") {
                    if availableFonts.isEmpty {
                        Text("No custom fonts found. Make sure you:")
                            .foregroundStyle(.secondary)
                        Text("1. Added the font file to the project")
                        Text("2. Registered it in Info.plist")
                        Text("3. Built the app")
                    } else {
                        ForEach(availableFonts, id: \.self) { fontName in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fontName)
                                    .font(.headline)
                                Text("Sample: قال الله تعالى")
                                    .font(.custom(fontName, size: 20))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section("System Fonts (for comparison)") {
                    Text("System Default")
                        .font(.system(.body))
                    Text("System Serif")
                        .font(.system(.body, design: .serif))
                }
            }
            .navigationTitle("Font Test")
            .onAppear {
                availableFonts = FontHelper.listAllFonts()
                print("Found fonts: \(availableFonts)")
            }
        }
    }
}

#Preview {
    FontTestView()
}

