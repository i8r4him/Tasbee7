//
//  DailyProgressStore.swift
//  Tasbee7
//
//  Which athkar the user has ticked in each daily sitting, so the Today card can show "7 of 25"
//  and the reader can continue where they left off. Only the last two weeks are kept.
//

import Foundation
import Observation

@Observable
final class DailyProgressStore {
    static let shared = DailyProgressStore()

    private static let storageKey = "today.progress"
    /// Sittings older than this many days are dropped when saving.
    static let keepDays = 14
    /// More ids than any chapter has; anything above comes from a tampered file.
    static let maxIdsPerSitting = 500

    private let defaults: UserDefaults
    private let calendar: Calendar
    private(set) var done: [String: Set<Int>]

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
        if let data = defaults.data(forKey: Self.storageKey),
           let stored = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            var clean: [String: Set<Int>] = [:]
            for (key, ids) in stored where DailyKey(storageKey: key) != nil {
                let valid = Set(ids.filter { $0 >= 0 && $0 < Self.maxIdsPerSitting })
                if !valid.isEmpty { clean[key] = valid }
            }
            done = clean
        } else {
            done = [:]
        }
    }

    func isDone(_ id: Int, in key: DailyKey) -> Bool {
        done[key.storageKey]?.contains(id) ?? false
    }

    func doneCount(in key: DailyKey) -> Int {
        done[key.storageKey]?.count ?? 0
    }

    /// Counts only ids that exist in a chapter of `total` athkar.
    func doneCount(in key: DailyKey, total: Int) -> Int {
        done[key.storageKey]?.filter { $0 < total }.count ?? 0
    }

    /// The first dhikr not ticked yet, or nil when all are done.
    func firstOpen(in key: DailyKey, total: Int) -> Int? {
        let ticked = done[key.storageKey] ?? []
        return (0..<total).first { !ticked.contains($0) }
    }

    func setDone(_ isDone: Bool, id: Int, in key: DailyKey, now: Date = .now) {
        guard id >= 0, id < Self.maxIdsPerSitting else { return }
        var ids = done[key.storageKey] ?? []
        if isDone { ids.insert(id) } else { ids.remove(id) }
        done[key.storageKey] = ids.isEmpty ? nil : ids
        save(now: now)
    }

    func toggle(_ id: Int, in key: DailyKey, now: Date = .now) {
        setDone(!isDone(id, in: key), id: id, in: key, now: now)
    }

    func reset(_ key: DailyKey, now: Date = .now) {
        done[key.storageKey] = nil
        save(now: now)
    }

    private func save(now: Date) {
        let oldest = calendar.date(byAdding: .day, value: -Self.keepDays, to: calendar.startOfDay(for: now)) ?? now
        done = done.filter { key, _ in
            guard let parsed = DailyKey(storageKey: key),
                  let parts = DailyKey.date(from: parsed.day),
                  let day = calendar.date(from: parts) else { return false }
            return day >= oldest
        }
        let plain = done.mapValues { $0.sorted() }
        if let data = try? JSONEncoder().encode(plain) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
