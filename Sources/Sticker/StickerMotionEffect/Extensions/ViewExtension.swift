//
//  ViewExtension.swift
//  Sticker
//
//  Created by Benjamin Pisano on 22/07/2026.
//

import SwiftUI

extension View {
    func stickerRotation3D(
        for motion: StickerMotion,
        in size: CGSize,
        intensity: Double
    ) -> some View {
        let xRotation: Double = motion.isActive && size.width > 0
            ? (motion.transform.x / size.width) * intensity : .zero
        let yRotation: Double = motion.isActive && size.height > 0
            ? (motion.transform.y / size.height) * intensity : .zero
        return rotation3DEffect(.radians(xRotation), axis: (0, 1, 0))
            .rotation3DEffect(.radians(yRotation), axis: (-1, 0, 0))
    }
}
