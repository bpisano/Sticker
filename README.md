# Sticker

A Swift Package that uses Metal shaders to apply a Pokemon-style foil effect to a view.

![Mouse cursor moving over a sticker effect](.github/images/effect.gif)

# Installation

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bpisano/sticker", .upToNextMajor(from: "2.0.0"))
]
```

# Usage

Use the `.stickerEffect()` view modifier to apply the effect to any view.

```swift
import Sticker

struct ContentView: View {
    var body: some View {
        Image(.stickerIcon)
            .stickerEffect()
    }
}
```

By default, the effect is not animated.

## Parameters

The following modifiers are available to customize the sticker effect:

| Modifier                       | Default Value | Description                                                   |
| ------------------------------ | ------------- | ------------------------------------------------------------- |
| `.stickerScale(_:)`            | 3.0           | Controls the overall scale of the effect pattern              |
| `.stickerColorIntensity(_:)`   | 0.8           | Adjusts the strength of the holographic effect                |
| `.stickerContrast(_:)`         | 0.9           | Modifies the contrast between light and dark areas            |
| `.stickerBlend(_:)`            | 0.4           | Controls how much the effect blends with the original content |
| `.stickerCheckerScale(_:)`     | 5.0           | Adjusts the scale of the checker pattern                      |
| `.stickerCheckerIntensity(_:)` | 1.2           | Controls the intensity of the checker effect                  |
| `.stickerNoiseScale(_:)`       | 100.0         | Adjusts the scale of the noise pattern                        |
| `.stickerNoiseIntensity(_:)`   | 1.2           | Controls the intensity of the noise effect                    |
| `.stickerLightIntensity(_:)`   | 0.3           | Adjusts the intensity of the light reflection                 |
| `.stickerPattern(_:)`          | diamond       | Modifies the checker pattern                                  |     

Example usage:

```swift
Image(.stickerIcon)
    .stickerEffect()
    .stickerColorIntensity(0.5)
    .stickerNoiseScale(200)
    .stickerLightIntensity(0.5)
```

## Motion

The effect can be animated using the `.stickerMotionEffect()` view modifier.

```swift
Image(.stickerIcon)
    .stickerEffect()
    .stickerMotionEffect(.pointerHover(intensity: 0.5))
```

Motion updates are animated with `.snappy` by default. Use the `animation` parameter to customize the animation.

```swift
Image(.stickerIcon)
    .stickerEffect()
    .stickerMotionEffect(.pointerHover(intensity: 0.5), animation: .bouncy)
```

Pass `nil` to disable the internal animation and take control externally with a scoped `.animation` view modifier.

```swift
Image(.stickerIcon)
    .animation(.spring) { view in
        view
            .stickerEffect()
            .stickerMotionEffect(.pointerHover(intensity: 0.5), animation: nil)
    }
```

### Decoupling motion from the shader

`.stickerMotionEffect()` applies the motion right where it is called and publishes it through the environment, driving every descendant `.stickerEffect()`. This lets you apply the shader to a subview — like the background of a card — while the motion moves the whole view.

```swift
CardView() // Contains an icon overlay.
    .background {
        RoundedRectangle(cornerRadius: 16)
            .fill(.white)
            .stickerEffect()
    }
    .stickerMotionEffect(.pointerHover)
```

The whole card rotates, including the icon, while only the background reacts to the motion with the foil effect.

The following motion effects are available:

| Effect                                                  | Description                                                                                                                                                                                                                              |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.pointerHover(intensity:)`                             | Apply a 3D transform that looks at the pointer. The `intensity` parameter controls the strength of the effect.                                                                                                                           |
| `.dragGesture(intensity:)`                              | Apply a 3D transform that follows drag gestures. The `intensity` parameter controls the strength of the effect.                                                                                                                          |
| `.accelerometer(_:updateInterval:)` | Apply a 3D transform based on the device's accelerometer data. The `AccelerometerBehavior` parameter controls how the attitude is applied: `.rotation(intensity:maxRotation:)` rotates the view (`intensity` controls the strength, `maxRotation` the angle the rotation smoothly approaches), while `.identity` only drives the sticker shaders without transforming the view. |

You can create your own motion effects by implementing the `StickerMotionEffect` protocol, which is a `ViewModifier`. A motion effect holds its own `StickerMotion` state, publishes it through the `\.stickerMotion` environment value so that descendant sticker effects can react to it, and wraps its state updates in `withAnimation` using the `\.stickerMotionAnimation` environment value set by `.stickerMotionEffect()`.

```swift
struct PressMotionEffect: StickerMotionEffect {
    @State private var motion: StickerMotion = .init()

    @Environment(\.stickerMotionAnimation) private var animation

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(motion.isActive ? 15 : 0), axis: (0, 1, 0))
            .onLongPressGesture(minimumDuration: 0) {
            } onPressingChanged: { isPressing in
                withAnimation(animation) {
                    motion = .init(
                        isActive: isPressing,
                        transform: isPressing ? .init(x: 40, y: 40) : .neutral
                    )
                }
            }
            .environment(\.stickerMotion, motion)
    }
}

extension StickerMotionEffect where Self == PressMotionEffect {
    static var press: Self { .init() }
}
```

## Compiling Shaders

On iOS 18, macOS 15 and visionOS 2, Apple added the ability to compile Metal shaders at runtime to prevent frame delay on first use. You can compile the Sticker shaders as soon as your app launches by calling the following function:

```swift
import SwiftUI
import Sticker

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await ShaderLibrary.compileStickerShaders()
                }
        }
    }
}
```
