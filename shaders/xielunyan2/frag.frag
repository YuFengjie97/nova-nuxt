#version 300 es
#define PI 3.1415926

precision mediump float;
uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;  // 输出颜色
in vec2 fragCoord;

float sdf_circle(vec2 uv, float radius) {
  return length(uv) - radius;
}
mat2 rotate(float angle){
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}


float sdf_gouyu(vec2 uv, float angle, float r ) {
    
    float r_half = r * 0.5;
    
    vec2 center = vec2(-r_half, 0.);
    uv *= rotate(angle);
    uv += center;

    float circle = sdf_circle(uv, r);
    
    float c_add = sdf_circle(uv-vec2(-r_half, 0.), r_half);
    float c_cut = sdf_circle(uv-vec2(r_half, 0.), r_half);
    float shape = max(circle, uv.y);
    shape = max(shape, -c_cut);
    shape = min(shape, c_add);
    
    return shape;
}

float gouyu(vec2 uv, vec2 pos, float angle, float r){
    float d = sdf_gouyu(uv-pos, angle, r);
    float aa = fwidth(d) * 2.;
    float s = smoothstep(aa, -aa, d);
    return s;
}

float circle(vec2 uv, vec2 pos, float r){
    float d = sdf_circle(uv-pos, r);
    float aa = fwidth(d) * 2.;
    return smoothstep(aa, -aa, d);
}

float circle_border(vec2 uv, vec2 pos, float r, float bw) {
    float d = sdf_circle(uv-pos, r);
    float aa = fwidth(d) * 2.;
    bw *= 0.5;
    return smoothstep(bw+aa, bw-aa, abs(d));
}

void main(){
    vec2 uv = (fragCoord-iResolution.xy*0.5)/iResolution.y;
    
    vec3 col = vec3(0.41, 0.43, 0.88);
    vec3 black = vec3(0.);
    vec3 red = vec3(0.76, 0.21, 0.09);
    // 最大红色圆形
    float c = circle(uv, vec2(0.), 0.4);
    col = mix(col, red, c);
    
    // 最外层border
    float b = circle_border(uv, vec2(0.), 0.4, 0.02);
    col = mix(col, black, b);
    
    // 中间border
    float r2 = 0.25;
    float b2 = circle_border(uv, vec2(0.), r2, 0.015);
    col = mix(col, black, b2);
    
    // 最中间黑圆
    float c2 = circle(uv, vec2(0.), 0.08);
    col = mix(col, black, c2);
    
    float a = PI * 2. / 3.;
    
    vec2 uv_r = uv * rotate(iTime * 2.);
    float t = abs(sin(iTime * 1.2));
    float gouyu_r = 0.1 * t;
    float gouyu_d = (r2 - gouyu_r * 0.5 + 0.02) * t;

    
    float g1 = gouyu(uv_r, vec2(cos(a)*gouyu_d, sin(a)*gouyu_d), PI*0.9, gouyu_r);
    col = mix(col, black, g1);
    float g2 = gouyu(uv_r, vec2(cos(a*2.)*gouyu_d, sin(a*2.)*gouyu_d), PI * 0.3, gouyu_r);
    col = mix(col, black, g2);
    float g3 = gouyu(uv_r, vec2(cos(a*3.)*gouyu_d, sin(a*3.)*gouyu_d), a + PI * 0.9, gouyu_r);
    col = mix(col, black, g3);

    fragColor = vec4(col,1.0);
}