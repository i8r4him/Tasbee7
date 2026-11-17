//
//  PhrasePickerSheet.swift
//  Tasbee7
//
//  Pick a phrase, add your own, or swipe to delete one you added.
//

import SwiftUI

struct PhrasePickerSheet: View {
    @Bindable var store: SebhaStore
    @Environment(\.dismiss) private var dismiss

    @State private var showsAdd = false
    @State private var newPhrase = ""
    @State private var picks = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(SebhaStore.basePhrases, id: \.self) { phrase in
                        row(phrase)
                    }
                }

                Section {
                    if store.customPhrases.isEmpty {
                        Text("أضف ذكراً تحبّه ليظهر هنا.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.customPhrases, id: \.self) { phrase in
                            row(phrase)
                        }
                        .onDelete(perform: store.deleteCustomPhrases)
                    }
                } header: {
                    Text("أذكارك")
                } footer: {
                    if !store.customPhrases.isEmpty {
                        Text("اسحب لحذف ذكر أضفته.")
                    }
                }
            }
            .softScroll()
            .navigationTitle("اختر الذكر")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newPhrase = ""
                        showsAdd = true
                    } label: {
                        Label("إضافة ذكر", systemImage: "plus")
                    }
                }
            }
            .alert("إضافة ذكر", isPresented: $showsAdd) {
                TextField("اكتب الذكر", text: $newPhrase)
                Button("إلغاء", role: .cancel) {}
                Button("إضافة") {
                    if store.addPhrase(newPhrase) {
                        dismiss()
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: picks)
        }
        .presentationDetents([.medium, .large])
    }

    private func row(_ phrase: String) -> some View {
        Button {
            store.select(phrase)
            picks += 1
            dismiss()
        } label: {
            HStack {
                Text(phrase)
                    .foregroundStyle(.primary)
                Spacer()
                if store.count(for: phrase) > 0 {
                    Text(store.count(for: phrase), format: .number)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                if store.selectedPhrase == phrase {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.accent)
                }
            }
            .frame(minHeight: Spacing.minTouchTarget)
            .contentShape(.rect)
        }
        .accessibilityAddTraits(store.selectedPhrase == phrase ? .isSelected : [])
    }
}
