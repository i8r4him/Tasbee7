//
//  AyahOfTheDay.swift
//  Tasbee7
//
//  One ayah a day from a short, hand-picked list. The text is the Tanzil "simple" Quran text, copied verbatim
//  (Tanzil Project, CC BY 3.0, tanzil.net) into ayat_of_the_day.json. Never edit the ayah text by hand.
//

import Foundation

struct Ayah: Decodable, Hashable {
    let surah: String
    let surahNumber: Int
    let ayah: Int
    let text: String

    /// "سورة البقرة · ١٥٢"
    var reference: String {
        "سورة \(surah) · \(ayah.formatted())"
    }

    var shareText: String {
        "﴿\(text)﴾\n\(reference)"
    }
}

enum AyahOfTheDay {
    private struct File: Decodable {
        let source: String
        let ayat: [Ayah]
    }

    /// Reads the list from the app bundle. Empty when the file is missing or broken, and the card then hides.
    static func load(bundle: Bundle = .main) -> [Ayah] {
        guard let url = bundle.url(forResource: "ayat_of_the_day", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return ayat(from: data)
    }

    static func ayat(from data: Data) -> [Ayah] {
        (try? JSONDecoder().decode(File.self, from: data))?.ayat.filter { !$0.text.isEmpty } ?? []
    }

    /// The same ayah all day, a different one each day, going through the whole list before repeating.
    static func pick(from ayat: [Ayah], on date: Date, calendar: Calendar = .current) -> Ayah? {
        guard !ayat.isEmpty else { return nil }
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let days = Int(PrayerCalculator.julianDay(year: parts.year ?? 2000, month: parts.month ?? 1, day: parts.day ?? 1))
        let index = ((days % ayat.count) + ayat.count) % ayat.count
        return ayat[index]
    }
}
