#version 300 es

precision mediump float;
uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;  // 输出颜色
in vec2 fragCoord;

#define PI 3.14159
#define T_PI 6.2831

float pix;

float sdf_circle(vec2 uv, float radius) {
   return length(uv) - radius;
}

// iq:  https://iquilezles.org/articles/distfunctions2d/
float sdf_box( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdf_gouyu(vec2 uv, float r) {
    
    float r_half = r * 0.5;
    
    // 最大的圆
    float circle = sdf_circle(uv, r);
    
    
    // 内部添加的小圆
    float c_add = sdf_circle(uv-vec2(-r_half, 0.), r_half);
    // 内部删除的小圆
    float c_cut = sdf_circle(uv-vec2(r_half, 0.), r_half);
    //c_cut = max(c_cut, -uv.y);
    
    // 最大的圆删去底部一半
    float shape = max(circle, -uv.y);
    
    // 最大的圆删去内部小圆
    shape = max(shape, -c_cut);
    
    // 最大的圆添加内部小圆
    shape = min(shape, c_add);
    
    return shape;
}

void main( )
{
    vec2 uv = (fragCoord - iResolution.xy * 0.5)/iResolution.y;
    
    pix = 1. / iResolution.y;

    vec2 pos = vec2(0.);
    //float r = 0.2;
    float r = 0.1 + 0.2 * (sin(iTime)*0.5+0.5);
    
    float a = iTime;
    mat2 rot = mat2(
        cos(a), -sin(a),
        sin(a),  cos(a)
    );
    
    
    // 勾玉
    //vec2 p = (uv - pos)*rot;
    vec2 p = uv - pos;
    // iq
    float d = sdf_gouyu(p, r);
    vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
    col *= 1.0 - exp(-6.0*abs(d));
	col *= 0.8 + 0.2*cos(150.0*d);
    col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.01,abs(d)) );
    

    fragColor = vec4(col,1.0);
}