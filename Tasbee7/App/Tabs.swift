//
//  Tabs.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 22.04.26.
//

import Foundation

enum Tabs {
    case home, sebha, search
    
    var name: String {
        switch self {
        case .home: return "الرئيسية"
        case .sebha: return "السبحة"
        case .search: return "البحث"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .sebha: return "point.3.connected.trianglepath.dotted"
        case .search: return "magnifyingglass"
        }
    }
}
