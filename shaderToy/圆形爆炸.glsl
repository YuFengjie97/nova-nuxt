#define PI 3.141596

#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"


float easeOut(float v){
  return sqrt(1. - pow(v - 1., 2.));
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  // 全局时间控制,加速或减速
  float T = iTime * .3;


  float angle = atan(uv.y, uv.x) / PI;
  float len = length(uv);
  vec2 p = vec2(angle, len);

  float d = 0.;
  for(float i=0.;i<4.;i++){

    // 时间缓动 与 时间偏移
    float t = easeOut(fract(T - 0.1 * i));

    // 圆圈的最小半径 与 爆炸半径
    float d = abs(p.y - t * 0.5 - 0.2);
    // 绘制圆圈形状
    float s = smoothstep(.1, 0., d);

    // 使用极坐标对噪音材质取值
    // 使用对数极坐标增加中心部分扭曲
    float mask = texture(iChannel0, vec2(p.x + i * 2.1, log(p.y) - t + i * 4.2)).r;
    // 增加0处特征范围 与 加强总体特征
    mask = smoothstep(0.5, 1., mask) * 2.;

    // 随着时间渐渐消失
    float fadeOut = smoothstep(1., 0.6,t);
    s *= mask * fadeOut;
    O.rgb += s * vec3(1.,0.,0.);
  }

}