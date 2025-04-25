#version 300 es
#define PI 3.1415926

precision mediump float;

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;  // 输出颜色
in vec2 fragCoord;


void main()
{
  vec2 uv = (fragCoord - iResolution.xy * 0.5)/iResolution.y;
    uv = vec2(atan(uv.y, uv.x) / 6.2831, length(uv));
    
    uv.x *= 3.;
    uv.x -= smoothstep(0.1, .8, uv.y);
    float v = fract(uv.x + iTime * 0.2) + 0.2 - uv.y * 3.1 + 0.3;
    float shape_flower = smoothstep(0., .05, v);
    float shape_circle = smoothstep(0.01, 0., uv.y - .45);
    float shape_circle_2 = smoothstep(0.01, 0., uv.y - .07);

    vec3 black = vec3(0.);
    vec3 red = vec3(1., 0., 0.);

    vec3 color = vec3(0.);
    color = mix(color, red, shape_circle);
    color = mix(color, black, shape_flower);
    color = mix(color, red, shape_circle_2);

    fragColor = vec4(color,1.0);
}