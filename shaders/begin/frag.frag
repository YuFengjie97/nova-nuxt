#version 300 es

precision mediump float;

uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D uTexture;

in vec2 fragCoord;
out vec4 fragColor;  // 输出颜色


const float PI = 3.1415926;


void main() {
    vec2 uv = (fragCoord * 2. - iResolution.xy)/iResolution.y;
    fragColor = texture(uTexture, uv);
}