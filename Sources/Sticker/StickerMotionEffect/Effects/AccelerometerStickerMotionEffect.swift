//
//  AccelerometerStickerMotionEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 15/11/2024.
//

#if os(iOS)
import SwiftUI
import CoreMotion

/// A motion effect that rotates its content with the device attitude.
public struct AccelerometerStickerMotionEffect: StickerMotionEffect {
    let intensity: Double
    let maxRotation: Angle
    let updateInterval: TimeInterval

    @State private var rotation: Rotation?
    @State private var size: CGSize = .zero

    @Environment(\.stickerMotionAnimation) private var animation

    /// Rotates the content with the device attitude and publishes the motion to descendants.
    /// - Parameter content: The view the effect modifies.
    /// - Returns: The content rotated by the current motion, publishing that motion to descendants.
    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(rotation?.x ?? .zero, axis: (0, 1, 0))
            .rotation3DEffect(rotation?.y ?? .zero, axis: (-1, 0, 0))
            .onAccelerometerUpdate(updateInterval: updateInterval) { attitude in
                withAnimation(animation) {
                    rotation = .init(
                        x: .radians(diminishingRotation(for: attitude.roll * intensity)),
                        y: .radians(diminishingRotation(for: attitude.pitch * intensity))
                    )
                }
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                size = newSize
            }
            .environment(\.stickerMotion, motion)
    }

    private var motion: StickerMotion {
        guard let rotation else { return .inactive }
        return .active(
            x: rotation.x.radians * size.width / 2,
            y: rotation.y.radians * size.height / 2
        )
    }

    private func diminishingRotation(for tilt: Double) -> Double {
        let scale: Double = 1 / (1 + abs(tilt) / maxRotation.radians)
        return tilt * scale
    }
}

private extension AccelerometerStickerMotionEffect {
    struct Rotation: Equatable {
        let x: Angle
        let y: Angle
    }
}

public extension StickerMotionEffect where Self == AccelerometerStickerMotionEffect {
    /// A motion effect that follows the device attitude with default parameters.
    static var accelerometer: Self {
        .accelerometer()
    }

    /// A motion effect that follows the device attitude.
    /// - Parameters:
    ///   - intensity: The strength of the rotation applied to the device tilt.
    ///   - maxRotation: The angle the rotation asymptotically approaches as the tilt grows.
    ///   - updateInterval: The interval at which the device motion is sampled.
    /// - Returns: An accelerometer motion effect.
    static func accelerometer(
        intensity: Double = 1,
        maxRotation: Angle = .degrees(90),
        updateInterval: TimeInterval = 0.02
    ) -> Self {
        .init(
            intensity: intensity,
            maxRotation: maxRotation,
            updateInterval: updateInterval
        )
    }
}
#endif
