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

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  a += T;
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
    p *= rotate(2.+T*.01);
    amp *= .5;
    fre *= 2.;
  }
  return n;
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
  vec2 m = (iMouse.xy*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;
  vec3 col = vec3(0);

  float s = 10.;
  uv *= s;
  m *= s;
  m = floor(m);

  vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);

  {
    vec2 g = uvf - .5;
    float grid = min(abs(g.x-.5), abs(g.y-.5));
    grid = S(50./R.y,0.,grid);
    col += grid;
  }
  

  vec2 sta = vec2(0);
  vec2 end = vec2(4,7);

  if(iMouse.z > 0.){
    end = m;
    col += m == uvi ? 1.: 0.;
  }

  float d_sta = uvi == sta ? 1. : 0.;
  col += d_sta * vec3(1,0,0);
  // col = mix(col, vec3(1,0,0), d_sta);

  vec2 dlt = end - sta;
  float k = dlt.y / dlt.x;

  float y_pre = sta.y;
  for(float i=0.;i<=end.x-sta.x;i++){
    float xi = sta.x+i;
    float yi = floor(y_pre + k);

    y_pre = yi;

    if(uvi.x==xi && uvi.y==yi){
      col += 1.;
    }
  }


  O.rgb = col;
}