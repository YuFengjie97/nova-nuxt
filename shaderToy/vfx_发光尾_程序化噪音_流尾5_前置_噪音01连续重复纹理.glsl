// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256_rgb.png"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
  return vec2(cos(a), sin(a));
}

/*
在01交界处连续的噪音方法
p---uv,必须是0到1,控制细节缩放交由tileSize
因为以01为范围参与取余操作,tileSize必须是整数
*/
float noise(vec2 p, vec2 tileSize){
  p *= tileSize;               // 提前设置,当前uv下有tileSize尺寸的细节
  vec2 i = floor(p);
  vec2 f = fract(p);
  i = mod(floor(i), tileSize); // 以tileSize为尺寸开始重复


  // 4个顶点的随机值也要进行mod取余重复
  vec2 g00 = randomGradient(mod(i+vec2(0,0), tileSize));
  vec2 g10 = randomGradient(mod(i+vec2(1,0), tileSize));
  vec2 g01 = randomGradient(mod(i+vec2(0,1), tileSize));
  vec2 g11 = randomGradient(mod(i+vec2(1,1), tileSize));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;
  // vec2 uv = (I-vec2(R.x/2.,R.y/2.))/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec2 uv2 = vec2((atan(uv.y, uv.x)+PI)/TAU, length(uv));
  
  // uv平铺
  uv *= 4.;
  uv = fract(uv);

  // 参考网格
  vec2 grid = fract(uv);
  grid = S(-2./R.y,.0,abs(grid-.5)-.5);
  float d_grid = max(grid.x,grid.y);
  O.rgb += d_grid * vec3(1,0,0);

  // vec2 tileSize = vec2(floor(s1(T)*6.)+2.);
  vec2 tileSize = vec2(floor(mod(floor(T), 5.))+vec2(3,2));
  // vec2 tileSize = vec2(6.);
  // vec2 tileSize = vec2(10.,7.);

  float n = noise(uv, tileSize);
  n = S(20./R.y,0.,n);

  O.rgb = mix(O.rgb, vec3(1), n);
}