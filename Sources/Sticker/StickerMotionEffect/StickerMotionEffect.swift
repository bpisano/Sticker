//
//  StickerMotionEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI

/// A view modifier that rotates its content in response to an input source and publishes
/// the resulting motion through the ``EnvironmentValues/stickerMotion`` environment value.
public protocol StickerMotionEffect: ViewModifier { }

public extension View {
    /// Applies a motion effect to this view.
    ///
    /// The effect rotates the view from its input source (drag gesture, pointer hover,
    /// accelerometer) and publishes its motion through the
    /// ``EnvironmentValues/stickerMotion`` environment value, driving every descendant
    /// `stickerEffect`.
    /// - Parameters:
    ///   - effect: The motion effect to apply.
    ///   - animation: The animation the effect uses for its motion updates. Pass `nil` to
    ///     disable internal animation and control it externally.
    /// - Returns: A view that moves with the given effect.
    func stickerMotionEffect(
        _ effect: some StickerMotionEffect,
        animation: Animation? = .stickerMotionDefault
    ) -> some View {
        modifier(effect)
            .environment(\.stickerMotionAnimation, animation)
    }
}

public extension EnvironmentValues {
    /// The animation that motion effects use when updating their motion.
    ///
    /// Set by `stickerMotionEffect(_:animation:)`. Custom ``StickerMotionEffect``
    /// implementations read this value and wrap their motion updates in `withAnimation`.
    @Entry var stickerMotionAnimation: Animation? = .stickerMotionDefault
}
