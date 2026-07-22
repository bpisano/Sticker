//
//  StickerEffect.swift
//  Sticker
//
//  Created by Benjamin Pisano on 03/11/2024.
//

import SwiftUI

private struct StickerEffectViewModifier: ViewModifier {
    @Environment(\.stickerMotion) private var motion
    @Environment(\.stickerScale) private var stickerScale
    @Environment(\.stickerColorIntensity) private var stickerColorIntensity
    @Environment(\.stickerContrast) private var stickerContrast
    @Environment(\.stickerBlend) private var stickerBlend
    @Environment(\.stickerCheckerScale) private var stickerCheckerScale
    @Environment(\.stickerCheckerIntensity) private var stickerCheckerIntensity
    @Environment(\.stickerNoiseScale) private var stickerNoiseScale
    @Environment(\.stickerNoiseIntensity) private var stickerNoiseIntensity
    @Environment(\.stickerLightIntensity) private var stickerLightIntensity
    @Environment(\.stickerPattern) private var stickerPattern

    func body(content: Content) -> some View {
        content
            .visualEffect { [motion, stickerLightIntensity] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.reflectionShader(
                            size: proxy.size,
                            reflectionPosition: CGPoint(
                                x: (motion.transform.x + proxy.size.width / 2) / proxy.size.width,
                                y: (motion.transform.y + proxy.size.height / 2) / proxy.size.height
                            ),
                            reflectionSize: Float(min(proxy.size.width, proxy.size.height) / 2),
                            reflectionIntensity: motion.isActive ? stickerLightIntensity : 0
                        )
                    )
            }
            .visualEffect {
                [
                    motion, stickerScale, stickerColorIntensity, stickerContrast, stickerBlend,
                    stickerCheckerScale, stickerCheckerIntensity, stickerNoiseScale,
                    stickerNoiseIntensity, stickerPattern
                ] view, proxy in
                view
                    .colorEffect(
                        ShaderLibrary.foilShader(
                            offset: motion.isActive
                                ? (motion.transform * -150).point : StickerTransform.neutral.point,
                            size: proxy.size,
                            scale: stickerScale,
                            intensity: stickerColorIntensity,
                            contrast: stickerContrast,
                            blendFactor: stickerBlend,
                            checkerScale: stickerCheckerScale,
                            checkerIntensity: stickerCheckerIntensity,
                            noiseScale: stickerNoiseScale,
                            noiseIntensity: stickerNoiseIntensity,
                            patternType: stickerPattern
                        )
                    )
            }
            .mask(content)
    }
}

public extension View {
    /// Applies a holographic sticker effect to this view.
    ///
    /// The effect reads the ``EnvironmentValues/stickerMotion`` environment value published by
    /// the nearest ancestor `stickerMotionEffect(_:animation:)` to drive its shaders.
    /// - Parameter isEnabled: Whether the effect is applied.
    /// - Returns: A view with the sticker effect applied when enabled.
    @ViewBuilder
    func stickerEffect(_ isEnabled: Bool = true) -> some View {
        if isEnabled {
            modifier(StickerEffectViewModifier())
        } else {
            self
        }
    }
}

#Preview("Card") {
    VStack(spacing: 20) {
        Image(systemName: "applelogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .foregroundStyle(.white)
        Text("Sticker")
            .font(.title.bold())
            .foregroundStyle(.black)
    }
    .padding(40)
    .background {
        RoundedRectangle(cornerRadius: 24)
            .fill(.white)
            .stickerEffect()
    }
    .stickerMotionEffect(.dragGesture)
    .shadow(radius: 20)
    .padding()
}

#Preview("Simple") {
    VStack {
        Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .stroke(.black, lineWidth: 2)
                    .padding(2)
            }
            .frame(height: 30)
            .stickerEffect()
            .stickerMotionEffect(.pointerHover)
            .shadow(radius: 20)
            .padding()

        Image(systemName: "applelogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 300)
            .foregroundStyle(.white)
            .stickerEffect()
            .stickerMotionEffect(.dragGesture)
            .shadow(radius: 20)
            .padding()
    }
}
