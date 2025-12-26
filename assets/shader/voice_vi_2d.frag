#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float iTime;
uniform float rmsAmplitude;
uniform float freq;
// uniform sampler2D iChannel0;

out vec4 fragColor;

// // Frequency values for different layers
// float frequencies[16];
// const vec2 zeroOne = vec2(0.0, 1.0);
// const float PI = 3.141592653589793238;

// const vec4 colorSurface = vec4(0.0, 0.0, 0.0, 0.0);
// const vec4 colorPrimary = vec4(0.000, 0.5725, 0.749, 1.0);


// // Rotate 2D vector by an angle
// mat2 rotate2d(float angle) {
//     return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
// }

// // 2D Hash function
// float hash2d(vec2 uv) {
//     float f = uv.x + uv.y * 47.0;
//     return fract(cos(f * 3.333) * 100003.9);
// }

// // Smoothly interpolate between two values
// float smoothInterpolation(float f0, float f1, float a) {
//     return mix(f0, f1, a * a * (3.0 - 2.0 * a));
// }

// // 2D Perlin noise function
// float noise2d(vec2 uv) {
//     vec2 fractUV = fract(uv.xy);
//     vec2 floorUV = floor(uv.xy);
//     float h00 = hash2d(floorUV);
//     float h10 = hash2d(floorUV + zeroOne.yx);
//     float h01 = hash2d(floorUV + zeroOne);
//     float h11 = hash2d(floorUV + zeroOne.yy);
//     return smoothInterpolation(
//         smoothInterpolation(h00, h10, fractUV.x),
//         smoothInterpolation(h01, h11, fractUV.x),
//         fractUV.y 
//     );
// }

// void main() {
//     vec2 uv = (FlutterFragCoord().xy * 2.0 - uSize.xy) / uSize.y;
//     // uv /= 200.0 / uSize.y;
//     uv *= 2.5;
    
//     mat2 rotate = rotate2d(iTime);
//     float noise = noise2d(uv + rotate[0].xy);        
//     float color = 0.0;

//     for (int i = 0; i < 16; i++) {
//         // frequencies[i] = clamp(1.75 * pow(texture(iChannel0, vec2(0.05 + 0.5 * float(i) / 16.0, 0.25)).x, 4.0), 0.0, 1.0);
//         frequencies[i] = sin(freq + float(i) * 0.1234) * rmsAmplitude * .33;
        
//         float wave = sqrt(sin((-(frequencies[i] * noise * PI) + ((uv.x * uv.x) + (uv.y * uv.y)))));
//         wave = smoothstep(0.8, 1.0, wave);
//         color += wave * frequencies[i] * 0.2;
//         wave = smoothstep(0.99999, 1.0, wave);
//         color += wave * 0.2;
//     }

//     fragColor = mix(colorSurface, colorPrimary, color);
// }


const float PI = 3.14159265;

const vec3 lightDir = vec3(-0.577, 0.577, 0.577);
float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

float smoothMin(float d1, float d2, float k){
    float h = exp(-k * d1) + exp(-k * d2);
    return -log(h) / k;
}

float sdSphere( in vec3 p, in float r )
{
    return length(p)-r;
}

float dFn(vec3 p){
    const float div = 7.;
    const float an = 2.*PI/div;
    float index = round(atan(p.y,p.x)/an);
    float pick = (index+1.)/div;
    vec4 spect = vec4(freq * iTime / 1000, iTime / 100., rmsAmplitude, 3.); // texture(iChannel0, vec2(pick,0.));
    float angrot = index*an;
    vec3 q = p;
    q.xy = mat2(cos(angrot),-sin(angrot),
                sin(angrot), cos(angrot))*q.xy;

    float r = 1.5;
    float lenxy = r*spect.x ;
    float d = sdSphere( abs(q) - vec3(lenxy, 0, .5*sqrt(pow(r,2.) - lenxy)), .2*lenxy );
    float d2 = sdSphere( p , 1. );
    return smoothMin(d, d2, 20.0);
}

vec3 norm(vec3 p){
    float d = 0.001;
    return normalize(vec3(
        dFn(p + vec3(  d, 0.0, 0.0)) - dFn(p + vec3( -d, 0.0, 0.0)),
        dFn(p + vec3(0.0,   d, 0.0)) - dFn(p + vec3(0.0,  -d, 0.0)),
        dFn(p + vec3(0.0, 0.0,   d)) - dFn(p + vec3(0.0, 0.0,  -d))
    ));
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec4 march(vec2 p){
            
    vec4 spect = vec4(freq * iTime / 1000, iTime / 100., rmsAmplitude, 3.); //texture(iChannel0, vec2(0,0.));
    spect = spect-.5;
    
    float rotate = spect.x*.5*PI + 1.5*iTime;
    vec3 target = vec3( 0.0, 0.0, 0.0 );
    float r = 5.;
    vec3 cPos = target + vec3( r*cos(rotate), 1.5*cos(.3*rotate), r*sin(rotate) );
    mat3 direction = setCamera( cPos, target, 0. );
    float fl = 2.0;
    vec3 ray = direction * normalize( vec3(p,fl) );
    
    float distance = 0.0;
    float rLen = 0.0;
    vec3  rPos = cPos;
    for(int i = 0; i < 64; i++){
        distance = dFn(rPos);
        rLen += distance;
        rPos = cPos + ray * rLen*.5;
    }
    
    vec4 col = vec4(0);
    if(abs(distance) < 0.001){
        vec3 normal = norm(rPos);
        float diff = clamp(dot(lightDir, normal), 0., 1.0);
        col = vec4(vec3(1.007*normal), 1.0);
    }else{
        col += vec4(0.5 + 0.5*cos(iTime+p.xyx+vec3(0,2,4)), 0);
    }
    return col;
}

void main()
{
    vec2 p = (FlutterFragCoord().xy * 2.0 - uSize.xy) / uSize.y;
    fragColor = march(p);
}
