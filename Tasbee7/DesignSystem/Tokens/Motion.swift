//
//  Motion.swift
//  Tasbee7
//
//  One calm ease-out curve, short durations, and a short fade with Reduce Motion.
//

import SwiftUI

enum Motion {
    /// The app's curve: cubic-bezier(.2, .8, .2, 1).
    static func easeOut(duration: TimeInterval) -> Animation {
        .timingCurve(0.2, 0.8, 0.2, 1, duration: duration)
    }

    /// Push: slide and fade, 0.4 s.
    static func push(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : easeOut(duration: 0.4)
    }

    /// Modal: rise and fade, 0.45 s.
    static func modal(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : easeOut(duration: 0.45)
    }

    static func pushTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .offset(x: 28).combined(with: .opacity)
    }

    static func modalTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .offset(y: 48).combined(with: .opacity)
    }
}

extension EnvironmentValues {
    /// The system Reduce Motion setting. Set once at the root; everything that moves reads it.
    @Entry var reducesMotion = false
}
