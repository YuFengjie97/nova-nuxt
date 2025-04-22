#version 300 es
#define PI 3.1415926

precision mediump float;

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform float noise_distort_scale;  // 扭曲噪音纹理缩放值
uniform float noise_distort_uv_scale;  // 扭曲噪音纹理缩放值
uniform float smooth_dist;  // 图形边缘模糊距离

in vec2 vUV;
out vec4 fragColor;  // 输出颜色
in vec2 fragCoord;


// iq祖师爷,调色板
vec3 palette(float t) {
  vec3 a = vec3(0.731, 1.098, 0.192);
  vec3 b = vec3(0.358, 1.090, 0.657);
  vec3 c = vec3(1.077, 0.360, 0.328);
  vec3 d = vec3(0.965, 2.265, 0.837);
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
    vec2 uv = (fragCoord.xy - iResolution.xy * 0.5)/iResolution.y;
    
    // 极坐标转换
    uv = vec2(atan(uv.x, uv.y), length(uv));
    
    // atan范围是[-PI, PI],角度归一化
    // 因为噪音材质图片在0,1位置不连续,这里把角度对称化
    uv.x = (abs(uv.x) / PI);
    
    
    float radius = 0.4;         // 主半径
    float border_width = 0.3;   // 环宽度

    // 距离归一化
    uv.y = (uv.y / (radius + border_width * 0.5 + smooth_dist));
    

    float n = abs(uv.y - radius);   //  距离值
    //  距离smooth处理,羽化
    float shape = smoothstep(border_width * 0.5 + smooth_dist,
                             border_width * 0.5 - smooth_dist,
                             n);

    //  动态uv,uv.y方向扩张
    vec2 uv_anime = uv + vec2(0., -1.) * iTime * 0.1;
    
    // 扭曲噪音纹理,并获取值
    vec4 noise_distort = texture(iChannel1, uv * noise_distort_uv_scale) * noise_distort_scale;
    
    // uv根据噪音随机偏移
    uv_anime.y = fract(uv_anime.y + noise_distort.g);
    
    
    // 使用扭曲的噪音纹理来获取主噪音的值
    vec4 noise_final = texture(iChannel0, uv_anime);   
    
    //  噪音叠加形状, 确定绘制范围
    float shape_noise = noise_final.r * shape;

    //  渐变颜色,太美丽了, 在取值上加入噪音通道, 增添差异与变化
    vec3 color = palette(iTime * 0.4 + noise_final.b) * shape_noise;   


    fragColor = vec4(color,1.0);
}