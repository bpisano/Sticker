//
//  DragStickerMotionEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 13/11/2024.
//

import SwiftUI

/// A motion effect that rotates its content while the user drags it.
public struct DragStickerMotionEffect: StickerMotionEffect {
    let intensity: Double

    @State private var motion: StickerMotion = .inactive

    @Environment(\.stickerMotionAnimation) private var animation

    /// Rotates the content with the drag gesture and publishes the motion to descendants.
    /// - Parameter content: The view the effect modifies.
    /// - Returns: The content rotated by the current motion, publishing that motion to descendants.
    public func body(content: Content) -> some View {
        content
            .withViewSize { view, size in
                view
                    .stickerRotation3D(for: motion.transform, in: size, intensity: intensity)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation(animation) {
                                    motion = .active(
                                        x: gesture.location.x - size.width / 2,
                                        y: gesture.location.y - size.height / 2
                                    )
                                }
                            }
                            .onEnded { _ in
                                withAnimation(animation) {
                                    motion = .inactive
                                }
                            }
                    )
            }
            .environment(\.stickerMotion, motion)
    }
}

public extension StickerMotionEffect where Self == DragStickerMotionEffect {
    /// A motion effect that follows the user's drag gesture with default intensity.
    static var dragGesture: Self {
        .dragGesture()
    }

    /// A motion effect that follows the user's drag gesture.
    /// - Parameter intensity: The strength of the rotation applied while dragging.
    /// - Returns: A drag gesture motion effect.
    static func dragGesture(intensity: Double = 1) -> Self {
        .init(intensity: intensity)
    }
}
