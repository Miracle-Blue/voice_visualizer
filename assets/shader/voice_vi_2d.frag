#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float iTime;
uniform sampler2D iChannel0;

out vec4 fragColor;

// Frequency values for different layers
float frequencies[16];
const vec2 zeroOne = vec2(0.0, 1.0);
const float PI = 3.141592653589793238;

const vec4 colorSurface = vec4(0.0, 0.0, 0.0, .0);
const vec4 colorPrimary = vec4(0.445, 0.0, 0.749, .5);


// Rotate 2D vector by an angle
mat2 rotate2d(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

// 2D Hash function
float hash2d(vec2 uv) {
    float f = uv.x + uv.y * 47.0;
    return fract(cos(f * 3.333) * 100003.9);
}

// Smoothly interpolate between two values
float smoothInterpolation(float f0, float f1, float a) {
    return mix(f0, f1, a * a * (3.0 - 2.0 * a));
}

// 2D Perlin noise function
float noise2d(vec2 uv) {
    vec2 fractUV = fract(uv.xy);
    vec2 floorUV = floor(uv.xy);
    float h00 = hash2d(floorUV);
    float h10 = hash2d(floorUV + zeroOne.yx);
    float h01 = hash2d(floorUV + zeroOne);
    float h11 = hash2d(floorUV + zeroOne.yy);
    return smoothInterpolation(
        smoothInterpolation(h00, h10, fractUV.x),
        smoothInterpolation(h01, h11, fractUV.x),
        fractUV.y
    );
}

void main() {
    vec2 uv = (FlutterFragCoord().xy * 2.0 - uSize.xy) / uSize.y;
    // uv /= 200.0 / uSize.y;
    uv *= 2.5;
    
    mat2 rotate = rotate2d(iTime * 5);
    float noise = noise2d(uv + rotate[0].xy);        
    float color = 0.0;

    for (int i = 0; i < 16; i++) {
        frequencies[i] = clamp(1.75 * pow(texture(iChannel0, vec2(0.05 + 0.5 * float(i) / 16.0, 0.25)).x, 4.0), 0.0, 1.0);
        //frequencies[i] = sin(iTime * (float(i) / 10000.0) + float(i) * 0.1234) * 0.25;
        
        float wave = sqrt(sin((-(frequencies[i] * noise * PI) + ((uv.x * uv.x) + (uv.y * uv.y)))));
        wave = smoothstep(0.8, 1.0, wave);
        color += wave * frequencies[i] * 0.2;
        wave = smoothstep(0.99999, 1.0, wave);
        color += wave * 0.2;
    }


    fragColor = mix(colorSurface, colorPrimary, color);
}
