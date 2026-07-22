//
//  ViewExtension.swift
//  Sticker
//
//  Created by Benjamin Pisano on 22/07/2026.
//

import SwiftUI

extension View {
    func stickerRotation3D(
        for transform: StickerTransform,
        in size: CGSize,
        intensity: Double
    ) -> some View {
        let xRotation: Double = (transform.x / size.width) * intensity
        let yRotation: Double = (transform.y / size.height) * intensity
        return rotation3DEffect(.radians(xRotation), axis: (0, 1, 0))
            .rotation3DEffect(.radians(yRotation), axis: (-1, 0, 0))
    }
}
