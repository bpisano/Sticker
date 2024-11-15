//
//  File.swift
//  Sticker
//
//  Created by Benjamin Pisano on 15/11/2024.
//

import SwiftUI
import CoreMotion

public struct AccelerometerStickerMotionEffect: StickerMotionEffect {
    let intensity: Double
    let maxRotation: Angle

    @Environment(\.stickerShaderUpdater) private var shaderUpdater

    public func body(content: Content) -> some View {
        content
            .withViewSize { view, size in
                view
                    .withAccelerometer { view, attitude in
                        let xRotation: Double = diminishingRotation(for: attitude.roll * intensity)
                        let yRotation: Double = diminishingRotation(for: attitude.pitch * intensity)

                        view
                            .rotation3DEffect(.radians(xRotation), axis: (0, 1, 0))
                            .rotation3DEffect(.radians(yRotation), axis: (-1, 0, 0))
                            .onChange(of: attitude) { oldValue, newValue in
                                shaderUpdater.update(
                                    with: .init(
                                        x: xRotation * size.width / 3,
                                        y: yRotation * size.height / 3
                                    )
                                )
                            }
                    }
            }
    }

    private func diminishingRotation(for tilt: Double) -> Double {
        let scale: Double = 1 / (1 + abs(tilt) / maxRotation.radians)
        return tilt * scale
    }
}

public extension StickerMotionEffect where Self == AccelerometerStickerMotionEffect {
    static var accelerometer: Self {
        .accelerometer()
    }

    static func accelerometer(
        intensity: Double = 1,
        maxRotation: Angle = .degrees(90)
    ) -> Self {
        .init(
            intensity: intensity,
            maxRotation: maxRotation
        )
    }
}