//
//  ArabicPlural.swift
//  Tasbee7
//
//  Arabic counts agree with the number: باب واحد، بابان، ٣ أبواب، ١١ باباً.
//

import Foundation

struct ArabicNoun {
    let one: String
    let two: String
    let few: String
    let many: String

    static let chapter = ArabicNoun(one: "باب واحد", two: "بابان", few: "أبواب", many: "باباً")
    static let dhikr = ArabicNoun(one: "ذكر واحد", two: "ذكران", few: "أذكار", many: "ذكراً")
    static let tasbiha = ArabicNoun(one: "تسبيحة واحدة", two: "تسبيحتان", few: "تسبيحات", many: "تسبيحة")
    static let result = ArabicNoun(one: "نتيجة واحدة", two: "نتيجتان", few: "نتائج", many: "نتيجة")

    /// "3 أبواب", "بابان", "11 باباً".
    func count(_ n: Int) -> String {
        switch n {
        case 1: return one
        case 2: return two
        default:
            let number = n.formatted()
            let rest = n % 100
            return "\(number) \((3...10).contains(rest) ? few : many)"
        }
    }
}
