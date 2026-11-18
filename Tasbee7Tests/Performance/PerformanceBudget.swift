//
//  PerformanceBudget.swift
//  Tasbee7Tests
//
//  Two kinds of check live in this folder:
//  - `measure` blocks: Xcode records a baseline per device and flags a run that gets slower than it.
//    Set the baselines once on a real device (Report navigator → the test → Set Baseline).
//  - Budgets: a hard ceiling that fails on any machine, so a big slowdown is caught even without
//    a baseline (CI, a new simulator). They are generous on purpose, for a Debug build on a slow
//    simulator; tighten them once real numbers are known.
//

import XCTest

enum Budget {
    /// Reading and decoding the whole book from the bundle.
    static let loadBook: TimeInterval = 0.30
    /// Building the repository: load + grouping + lookups.
    static let buildRepository: TimeInterval = 0.40
    /// One search over the whole book, the worst case (a word in almost every dhikr).
    static let searchWorstCase: TimeInterval = 0.25
    /// One keystroke of search-as-you-type. Below one frame budget × a few, so typing stays smooth.
    static let searchKeystroke: TimeInterval = 0.10
    /// Sunrise and sunset for a whole year at one place.
    static let solarYear: TimeInterval = 0.05
    /// The 60 reminder times the scheduler computes (2 kinds × 30 days).
    static let reminderTimes: TimeInterval = 0.01
    /// One tasbih tap, including saving the count.
    static let sebhaTap: TimeInterval = 0.002
}

extension XCTestCase {
    /// Runs `block` a few times and fails when the median time is over `budget`.
    /// The median ignores one slow first run (cold caches) or a hiccup on a busy machine.
    func assertMedianTime(
        under budget: TimeInterval,
        runs: Int = 5,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () throws -> Void
    ) rethrows {
        var times: [TimeInterval] = []
        for _ in 0..<runs {
            let start = DispatchTime.now().uptimeNanoseconds
            try block()
            times.append(TimeInterval(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000_000)
        }
        let median = times.sorted()[runs / 2]
        XCTAssertLessThan(
            median, budget,
            "\(label): median \(Self.ms(median)) is over the \(Self.ms(budget)) budget (runs: \(times.map(Self.ms)))",
            file: file, line: line
        )
    }

    private static func ms(_ seconds: TimeInterval) -> String {
        String(format: "%.2f ms", seconds * 1000)
    }
}
