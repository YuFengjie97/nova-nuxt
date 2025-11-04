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
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  // vec3 a = vec3(0.5, 0.5, 0.5);
  // vec3 b = vec3(0.5, 0.5, 0.5);
  // vec3 c = vec3(1.0, 1.0, 1.0);
  // vec3 d = vec3(0.0, 0.1, 0.2);

  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(2.0, 1.0, 0.0);
  vec3 d = vec3(0.5, 0.2, 0.25);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
}

float fbmWrap(vec2 p){
  vec2 q = vec2(
                fbm(p+vec2(13.24,42.74)),
                fbm(p+vec2(51.16,17.93))
                );

  float d = fbm(q);
  return d;
}


float shape(vec2 p){
  float d = abs(fbmWrap(p*3.)*.2-p.y);
  d*= 10.;
  return 1.-d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-vec2(0.,R.y/2.))/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  // 参考网格
  vec2 grid = fract(uv/.1);
  grid = S(-10./R.y,.0,abs(grid-.5)-.5);
  float d_grid = max(grid.x,grid.y);
  // O.rgb += d_grid;

  // 溶解形状
  float n = fbmWrap(uv*vec2(.4,2.)+vec2(-T*.5,0.));
  vec3 col = s1(vec3(3,2,1)+n*5.+T); // 根据溶解形状的距离场来确定颜色
  // vec3 col = palette(n*.5);     // 或者使用iq的调色板

  float s_n = n;                   // 溶解形状  
  s_n = s_n - uv.x + .8;           // 溶解形状根据uv.x进行衰减,减法的衰减最好,因为方便的取到0
  // s_n *= 4.;                    // 乘法可以加强特征 
  // s_n = clamp(s_n, 0., 1.);
  // s_n = pow(s_n, 2.);
  // O.rgb += s_n;

  // uv.y重复,绘制多条线
  // uv.y = sin(uv.y*20.)/20.;

  // 噪音产生的线形-主形状(使用绘制的透明材质或者用程序噪音来生成)
  // float d = abs(noise(uv*4.-vec2(T*6.,0.))*.1-uv.y);
  float d = abs(fbmWrap(uv*vec2(.1,1.)+vec2(-T*.3,0.))*.5-uv.y);
  d *= 1.-s_n;                     // 形状应用溶解
  d = pow(.02/d,2.);               // 发光

  O.rgb += d * col;
}