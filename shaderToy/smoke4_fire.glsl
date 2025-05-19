#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

// 可自定义外层,内层颜色,火焰!

#define PI 3.141596
#define BaseRadius 0.5
#define NoiseRadius .4
#define scale vec2(0.02)
#define offset vec2(0., -iTime * 5e-3)
// #define offset vec2(0., 5e-3)

float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    n += a * texture(iChannel0, p * f).r;
    f *= 2.;
    a *= .5;
  }
  return n;
}


vec2 twistUV(vec2 p){
  p *= scale;
  p += offset;
  return p;
}

float domainWraping(vec2 p){
  // return fbm(twistUV(p));
  return fbm(twistUV(p + fbm(twistUV(p))));
}


float getBlenderNoise(vec2 uv){
  vec2 q = vec2(atan(uv.y, uv.x), (length(uv)));
  vec2 q2= vec2(atan(uv.y,-uv.x), (length(uv)));

  float nR = domainWraping(q);
  nR *= smoothstep(-BaseRadius,0.,uv.x);

  float nL = domainWraping(q2+vec2(.1,.2));
  nL *= smoothstep(BaseRadius,0.,uv.x);

  float n = max(nR, nL);

  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  O.rgb *= 0.;
  O.a = 1.;


  float d = abs(length(uv)-BaseRadius);
  float s = smoothstep(NoiseRadius, 0., d);

  float n = getBlenderNoise(uv); // 获取噪音
  n *= s;                        // 噪音限制范围
  n *= 1.4;                      // 特征加强

  float f = .1;

  float v1 = .5;
  float s1 = smoothstep(v1,v1+f, n);
  vec3 c_o = vec3(1.,0.,0.);
  vec3 c = c_o * s1;

  float v2 = v1 + .2;
  float s2 = smoothstep(v2,v2+f, n);
  vec3 c_i = vec3(1.,1.,0.);
  c = mix(c, c_i, s2);

  O.rgb += c;
}