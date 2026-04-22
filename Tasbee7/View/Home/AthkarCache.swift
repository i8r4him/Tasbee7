//
//  AthkarCache.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation
import Observation

@MainActor
@Observable
final class AthkarCache {
    static let shared = AthkarCache()
    
    private(set) var sections: [AthkarSection] = []
    private(set) var loadError: Error?
    
    private let loader = AthkarLoader()
    private let cacheURL: URL
    
    private init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheURL = cacheDir.appendingPathComponent("athkar_sections_cache.json")
        
        // Try to load from cache first (fast, synchronous)
        if !loadFromCache() {
            // Cache doesn't exist - load from bundle and save to cache (first launch only)
            loadFromBundle()
        }
    }
    
    /// Load data from disk cache (returns true if successful)
    private func loadFromCache() -> Bool {
        guard FileManager.default.fileExists(atPath: cacheURL.path),
              let data = try? Data(contentsOf: cacheURL),
              let decoded = try? JSONDecoder().decode([AthkarSection].self, from: data) else {
            return false
        }
        sections = decoded
        return true
    }
    
    /// Load data from JSON bundle and save to cache (first launch only)
    private func loadFromBundle() {
        do {
            let loaded = try loader.load()
            sections = loaded
            saveToCache(loaded)
            loadError = nil
        } catch {
            loadError = error
        }
    }
    
    /// Save data to disk cache
    private func saveToCache(_ sections: [AthkarSection]) {
        guard let data = try? JSONEncoder().encode(sections) else { return }
        try? data.write(to: cacheURL)
    }
    
    /// Clear cache (useful for testing or if user wants to reset)
    func clearCache() {
        try? FileManager.default.removeItem(at: cacheURL)
        sections = []
        // Reload from bundle after clearing
        loadFromBundle()
    }
}

