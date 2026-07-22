//
//  PointerHoverStickerMotionEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI

/// A motion effect that rotates its content while the pointer hovers over it.
public struct PointerHoverStickerMotionEffect: StickerMotionEffect {
    let intensity: Double

    @State private var motion: StickerMotion = .inactive
    @State private var size: CGSize = .zero

    @Environment(\.stickerMotionAnimation) private var animation

    /// Rotates the content with the pointer location and publishes the motion to descendants.
    /// - Parameter content: The view the effect modifies.
    /// - Returns: The content rotated by the current motion, publishing that motion to descendants.
    public func body(content: Content) -> some View {
        content
            .stickerRotation3D(for: motion, in: size, intensity: intensity)
            .onContinuousHover { phase in
                switch phase {
                case let .active(location):
                    withAnimation(animation) {
                        motion = .active(
                            x: location.x - size.width / 2,
                            y: location.y - size.height / 2
                        )
                    }
                case .ended:
                    withAnimation(animation) {
                        motion = .inactive
                    }
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                size = newSize
            }
            .environment(\.stickerMotion, motion)
    }
}

public extension StickerMotionEffect where Self == PointerHoverStickerMotionEffect {
    /// A motion effect that follows the pointer with default intensity.
    static var pointerHover: Self {
        .pointerHover()
    }

    /// A motion effect that follows the pointer while it hovers over the view.
    /// - Parameter intensity: The strength of the rotation applied while hovering.
    /// - Returns: A pointer hover motion effect.
    static func pointerHover(intensity: Double = 1) -> Self {
        .init(intensity: intensity)
    }
}
