#version 300 es
#define PI 3.1415926

precision mediump float;

uniform float uTime;
uniform sampler2D texNoise;
uniform sampler2D texDistort;

in vec2 vUV;
out vec4 fragColor;  // 输出颜色

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d){ return a + b*cos( 6.28318*(c*t+d) ); }


const float DistortStength = 0.2;

void main() {
    vec2 uv = fract(vUV);

    vec2 uv_anime = uv;
    // uv_anime.x += sin(uTime) * 0.01;
    uv_anime.y += uTime * 0.05;

    vec4 noise = texture(texNoise, uv_anime);
    vec4 noise_distort = texture(texDistort, uv) * DistortStength;
    vec4 noise_final = texture(texNoise, fract(uv_anime + noise_distort.rg));

    float gradient = mix(0., 2., uv.y - 0.6);
    // float gradient = 1. - smoothstep(0.7, 0.3, uv.y);
    float n = noise_final.r + gradient;
    if(n < 0.) {
        fragColor = vec4(0.,0.,0.,0.);
        return;
    }

    vec3 color = n * mix(vec3(1.,1.,0.), vec3(1.,0.,0.), uv.y);
    // vec3 color = n * palette(uv.y, vec3(0.5, 0.5, 0.5),vec3(0.5, 0.5, 0.5),vec3(2.0, 1.0, 0.0),vec3(0.50, 0.20, 0.25));

    fragColor = vec4(color, 1.);
}