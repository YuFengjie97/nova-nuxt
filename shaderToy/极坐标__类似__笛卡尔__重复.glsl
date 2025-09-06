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


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec2 p = vec2(abs(atan(uv.y, uv.x)), length(uv));  // 这里abs的原因是atan的角度在-PI-PI处断裂

  // 极坐标R分段重复
  float sy = .1;              // 重复分段尺寸
  float idy = round(p.y/sy);
  float y = idy*sy;
  p.y -= y;

  p.x *= y;   // 角度按照距离来缩放

  // 极坐标角度重复
  float sx = TAU / (30.);       // 重复分段尺寸
  float idx = round(p.x/sx);
  float x = idx*sx;
  p.x -= x;


  float maxR = min(sx*y,sy) / 2.;


  float d = length(p) - maxR * .8;
  d = d < 0. ? 0. : d;
  vec3 c = 1.1+sin(vec3(3,2,1) + idx + idy);
  d = S(0.01,0.,d);
  O.rgb += d*c;
}