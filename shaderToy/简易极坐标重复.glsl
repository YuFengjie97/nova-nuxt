// 对 https://www.shadertoy.com/view/XftcRl  分析

/*
一般极坐标不能直接使用笛卡尔系的距离场函数
但是这里角度经过以R标准压缩, 相对标准的笛卡尔系, 每个重复的角度网格类似形成了较小扭曲的笛卡尔系(总体来看其实还是极坐标)
*/

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec2 p = vec2(atan(uv.y, uv.x), length(uv));
  // 极坐标R分段重复
  float sy = .1;              // 重复分段尺寸
  float y = round(p.y/sy)*sy;
  p.y -= y;

  // 极坐标角度重复
  float sx = TAU / 20.;       // 重复分段尺寸
  float x = round(p.x/sx)*sx;
  p.x -= x;
  p.x *= y;   // 角度按照距离来缩放

  float maxR = min(sx*y,sy) / 2.;


  float d = length(p) - maxR * .45;
  d = S(0.01,0.,d);
  O.rgb += d;
}