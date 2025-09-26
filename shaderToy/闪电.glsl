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

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

// float hash(vec2 p){
//   return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
// }
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


vec2 randomGradient(vec2 p){
  float a = hash12(p)*TAU;
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
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(fre*p)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float shape(vec2 p){
  // p.x = floor(p.x/.2);
  float n = noise(p*.4);
  float d = p.y - n;
  return d;
}

/**
v-值
t-目标
k-v的值变动,k的值可能超过v,用clamp限制在0-1
*/
float remap(float vmin, float vmax, float tmin,float tmax, float k){
  return clamp((k-vmin)/(vmax-vmin), 0., 1.) * (tmax-tmin) + tmin;
}

float gradient(vec2 p){
  float d = shape(p);
  vec2 h = vec2( 0.01, 0.0 );
  vec2 g = vec2(shape(p+h.xy) - shape(p-h.xy),
                shape(p+h.yx) - shape(p-h.yx) )/(2.0*h.x);
  // return abs(d) / length(g);
  return (g.x+g.y)*.5+.5;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  float f = fbm(uv*4.+vec2(T*4.,0.));
  /*
    主体形状是abs(uv.x),直线
    noise是主要的摆动,大振幅
    f是fbm细节
  */
  float d = abs(uv.x + noise(uv+vec2(0.,T*6.))*.3 + f*.1);

  // 因为是用pow(r/d,ins)的方式来发光,避免发光部分出现过多的fbm细节,这里用smoothstep限制范围
  d = 1.-S(200./R.y,0.,d);
  // 可以理解为透明度,alpha
  float a = 1.;
  
  // 时间周期
  float t = fract(T/4.);
  float ti = floor(T/4.);
  vec3 col = palette(ti*.1); // 根据周期切换颜色

  float ha = hash11(t*2.);

  // 闪电落下
  if(t<.4){
    float gradient = -remap(0.,.4,-2.,2.,t*2.);
    a = S(gradient, gradient+.1, uv.y);
  }
  // 闪电闪烁
  else{
    a = step(.3, ha);
  }

  // 发光部分,发光半径由基础半径和hash控制的闪烁来决定
  // a来控制闪电的显示与否
  float glow = pow((.04*ha+.01)/d, 2.) * a;

  O.rgb = glow * col;
}