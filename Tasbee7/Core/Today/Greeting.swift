//
//  Greeting.swift
//  Tasbee7
//
//  "صباح الخير" in the morning, "مساء الخير" after noon, with a symbol for the part of the day.
//

import Foundation

enum Greeting: Equatable {
    case morning, afternoon, night

    /// Morning from 4 am to noon, afternoon until 6 pm, night otherwise.
    init(hour: Int) {
        switch hour {
        case 4..<12: self = .morning
        case 12..<18: self = .afternoon
        default: self = .night
        }
    }

    init(at date: Date, calendar: Calendar = .current) {
        self.init(hour: calendar.component(.hour, from: date))
    }

    var text: String {
        switch self {
        case .morning: "صباح الخير"
        case .afternoon, .night: "مساء الخير"
        }
    }

    var systemImage: String {
        switch self {
        case .morning: "sun.max.fill"
        case .afternoon: "sun.haze.fill"
        case .night: "moon.stars.fill"
        }
    }
}
