//
//  StickerMotion.swift
//  Sticker
//
//  Created by Benjamin Pisano on 04/11/2024.
//

import SwiftUI

/// The state of a sticker motion effect at a given moment.
///
/// Motion effects publish their current motion through the ``EnvironmentValues/stickerMotion``
/// environment value so that every descendant `stickerEffect` can drive its shaders from it.
public struct StickerMotion: Hashable, Equatable, Sendable {
    /// The motion state of an effect that is not receiving input.
    public static let inactive: Self = .init()

    /// Whether the motion effect is currently receiving input.
    public var isActive: Bool = false

    /// The current position of the motion, relative to the center of the view.
    public var transform: StickerTransform = .neutral

    /// Creates a motion state.
    /// - Parameters:
    ///   - isActive: Whether the motion effect is currently receiving input.
    ///   - transform: The current position of the motion, relative to the center of the view.
    public init(
        isActive: Bool = false,
        transform: StickerTransform = .neutral
    ) {
        self.isActive = isActive
        self.transform = transform
    }

    /// Creates an active motion state at the given position.
    /// - Parameters:
    ///   - x: The horizontal position of the motion, relative to the center of the view.
    ///   - y: The vertical position of the motion, relative to the center of the view.
    /// - Returns: An active motion state at the given position.
    public static func active(x: Double, y: Double) -> Self {
        .init(isActive: true, transform: .init(x: x, y: y))
    }
}

public extension EnvironmentValues {
    /// The motion published by the nearest ancestor sticker motion effect.
    ///
    /// Custom ``StickerMotionEffect`` implementations write this value from their body with
    /// `environment(_:_:)`; `stickerEffect` reads it to drive its shaders.
    @Entry var stickerMotion: StickerMotion = .inactive
}
