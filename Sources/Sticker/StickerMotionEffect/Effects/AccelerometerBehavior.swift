//
//  AccelerometerBehavior.swift
//  Sticker
//
//  Created by Benjamin Pisano on 22/07/2026.
//

#if os(iOS)
import SwiftUI

/// The way an accelerometer motion effect applies the device attitude to its content.
public enum AccelerometerBehavior: Equatable, Sendable {
    /// Publishes the motion to descendants without transforming the content.
    case identity
    /// Rotates the content with the device attitude.
    /// - Parameters:
    ///   - intensity: The strength of the rotation applied to the device tilt.
    ///   - maxRotation: The angle the rotation asymptotically approaches as the tilt grows.
    case rotation(intensity: Double, maxRotation: Angle)

    /// Rotates the content with the device attitude using default parameters.
    public static let rotation: Self = .rotation(intensity: 1, maxRotation: .degrees(90))
}
#endif
