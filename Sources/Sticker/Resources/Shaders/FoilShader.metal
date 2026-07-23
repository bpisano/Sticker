//
//  FoilShader.metal
//  FoilTest
//
//  Created by Benjamin Pisano on 31/10/2024.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

// A helper function to generate pseudo-random noise based on position
float random(float2 uv) {
    return fract(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453);
}

// Helper function to calculate brightness
float calculateBrightness(half4 color) {
    return (color.r * 0.299 + color.g * 0.587 + color.b * 0.114);
}

float noisePattern(float2 uv) {
    float2 i = floor(uv);
    float2 f = fract(uv);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    // Smooth Interpolation
    float2 u = smoothstep(0.0, 1.0, f);

    // Mix 4 corners percentages
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Function to mix colors with more intensity on lighter colors
half4 lightnessMix(half4 baseColor, half4 overlayColor, float intensity, float baselineFactor) {
    // Calculate brightness of the base color
    float brightness = calculateBrightness(baseColor);

    // Adjust mix factor based on brightness, with a minimum baseline for darker colors
    float adjustedMixFactor = max(smoothstep(0.2, 1.0, brightness) * intensity, baselineFactor);

    // Perform color mixing
    return mix(baseColor, overlayColor, adjustedMixFactor);
}

// Function to increase contrast based on a pattern value
half4 increaseContrast(half4 source, float pattern, float intensity) {
    // Calculate the brightness of the source color
    float brightness = calculateBrightness(source);

    // Determine the amount of contrast to apply, based on pattern and brightness
    float contrastFactor = mix(1.0, intensity, pattern * brightness);

    // Center the source color around 0.5, apply contrast adjustment, then re-center
    half4 contrastedColor = (source - half4(0.5)) * contrastFactor + half4(0.5);

    return contrastedColor;
}

float squarePattern(float2 uv, float scale, float degreesAngle) {
    float radiansAngle = degreesAngle * M_PI_F / 180;

    // Scale the UV coordinates
    uv *= scale;

    // Rotate the UV coordinates by the specified angle
    float cosAngle = cos(radiansAngle);
    float sinAngle = sin(radiansAngle);
    float2 rotatedUV = float2(
                              cosAngle * uv.x - sinAngle * uv.y,
                              sinAngle * uv.x + cosAngle * uv.y
                              );

    // Determine if the current tile is black or white
    return fmod(floor(rotatedUV.x) + floor(rotatedUV.y), 2.0) == 0.0 ? 0.0 : 1.0;
}

float diamondPattern(float2 uv, float scale) {
    // Hardcoded angle of 45 degrees for the diamond pattern
    return squarePattern(uv, scale, 45.0);
}

float stickerPattern(int option, float2 uv, float scale) {
    switch (option) {
        case 0:
            return diamondPattern(uv, scale);
        case 1:
            return squarePattern(uv, scale, 0.0);
        default:
            return diamondPattern(uv, scale); // Default as diamond for unspecified options
    }
}

[[ stitchable ]] half4 foil(
                            float2 position,
                            half4 color,
                            float2 offset,
                            float2 size,
                            float scale,
                            float intensity,
                            float contrast,
                            float blendFactor,
                            float checkerScale,
                            float checkerIntensity,
                            float noiseScale,
                            float noiseIntensity,
                            float patternType,
                            half4 tint
) {
    // Calculate aspect ratio (width / height)
    float aspectRatio = size.x / size.y;

    // Normalize the offset by dividing by size to keep it consistent across different view sizes
    float2 normalizedOffset = (offset + size * 250) / (size * scale) * 0.01;
    float2 normalizedPosition = float2(position.x * aspectRatio, position.y);

    // Adjust UV coordinates by adding the normalized offset, then apply scaling
    float2 uv = (position / (size * scale)) + normalizedOffset;

    // Scale the noise based on the normalized position and noiseScale parameter
    float gradientNoise = random(position) * 0.1;
    float pattern = stickerPattern(patternType, normalizedPosition / size * checkerScale, checkerScale);
    float noise = noisePattern(position / size * noiseScale);

    // Calculate less saturated color shifts for a metallic effect
    half r = half(contrast + 0.25 * sin(uv.x * 10.0 + gradientNoise));
    half g = half(contrast + 0.25 * cos(uv.y * 10.0 + gradientNoise));
    half b = half(contrast + 0.25 * sin((uv.x + uv.y) * 10.0 - gradientNoise));

    half4 rainbow = half4(r, g, b, 1.0);

    // Soft satin folds for the tinted foil: two octaves of smooth value noise
    float folds = noisePattern(uv * 6.0) * 0.65 + noisePattern(uv * 14.0) * 0.35;
    float sheen = smoothstep(0.2, 0.95, folds);

    half3 tintBase = tint.rgb / max(tint.a, half(1e-4));
    half3 tintedRgb = mix(tintBase * 0.85, half3(1.0), half(sheen * 0.85));
    half4 tinted = half4(tintedRgb, 1.0);
    half4 foilColor = mix(rainbow, tinted, tint.a);
    half4 mixedFoilColor = lightnessMix(color, foilColor, intensity, 0.3);
    half4 checkerFoil = increaseContrast(mixedFoilColor, pattern, checkerIntensity);
    half4 noiseCheckerFoil = increaseContrast(checkerFoil, noise, noiseIntensity);

    return noiseCheckerFoil;
}
