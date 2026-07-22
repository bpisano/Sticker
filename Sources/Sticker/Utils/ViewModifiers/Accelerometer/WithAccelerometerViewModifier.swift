//
//  WithAccelerometerViewModifier.swift
//  Sticker
//
//  Created by Benjamin Pisano on 15/11/2024.
//

#if os(iOS)
import SwiftUI
import CoreMotion

private struct WithAccelerometerViewModifier: ViewModifier {
    let updateInterval: TimeInterval
    let onUpdate: (AccelerometerAttitude) -> Void

    private let motionManager = CMMotionManager()

    @State private var referenceAttitude: AccelerometerAttitude?

    func body(content: Content) -> some View {
        content
            .onAppear {
                startMotionUpdates()
            }
            .onDisappear {
                stopMotionUpdates()
            }
    }

    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion, error == nil else { return }
            var currentAttitude: AccelerometerAttitude = .init(attitude: motion.attitude)

            DispatchQueue.main.async {
                if referenceAttitude == nil {
                    referenceAttitude = currentAttitude
                }

                if let referenceAttitude {
                    currentAttitude = currentAttitude - referenceAttitude
                }

                onUpdate(currentAttitude)
            }
        }
    }

    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

extension View {
    func onAccelerometerUpdate(
        updateInterval: TimeInterval,
        _ onUpdate: @escaping (_ attitude: AccelerometerAttitude) -> Void
    ) -> some View {
        modifier(
            WithAccelerometerViewModifier(
                updateInterval: updateInterval,
                onUpdate: onUpdate
            )
        )
    }
}

#endif
