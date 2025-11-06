// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256_rgb.png"

// #define T sin(iTime*0.1)/0.1
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
  for(float i =0.;i<3.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
}

// ------3d------

float hash13(vec3 p3)
{
	  p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 randomGradient(vec3 p){
  float the = hash13(p)*TAU;
  float phi = hash13(p+vec3(3,2,1))*TAU;
  return vec3(sin(the)*cos(phi), sin(the)*sin(phi), cos(the));

  // float z = hash13(p)*2.0 - 1.0;        // 均匀分布在 [-1,1]
  // float a = hash13(p+vec3(3,2,1)) * TAU; 
  // float r = sqrt(1.0 - z*z);
  // return vec3(r*cos(a), r*sin(a), z);
}

float noise(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);

  vec3 g000 = randomGradient(i+vec3(0,0,0));
  vec3 g100 = randomGradient(i+vec3(1,0,0));
  vec3 g010 = randomGradient(i+vec3(0,1,0));
  vec3 g001 = randomGradient(i+vec3(0,0,1));
  vec3 g011 = randomGradient(i+vec3(0,1,1));
  vec3 g101 = randomGradient(i+vec3(1,0,1));
  vec3 g110 = randomGradient(i+vec3(1,1,0));
  vec3 g111 = randomGradient(i+vec3(1,1,1));

  float v000 = dot(g000, f-vec3(0,0,0));
  float v100 = dot(g100, f-vec3(1,0,0));
  float v010 = dot(g010, f-vec3(0,1,0));
  float v001 = dot(g001, f-vec3(0,0,1));
  float v011 = dot(g011, f-vec3(0,1,1));
  float v101 = dot(g101, f-vec3(1,0,1));
  float v110 = dot(g110, f-vec3(1,1,0));
  float v111 = dot(g111, f-vec3(1,1,1));

  // vec3 u = smoothstep(0.,1.,f);
  vec3 u = f*f*f*(f*(f*6.0 - 15.0) + 10.0);


  float mx1 = mix(v000, v100, u.x);
  float mx2 = mix(v010, v110, u.x);
  float mx3 = mix(v001, v101, u.x);
  float mx4 = mix(v011, v111, u.x);
  float my1 = mix(mx1, mx2, u.y);
  float my2 = mix(mx3, mx4, u.y);
  float mz = mix(my1, my2, u.z);
  return mz;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += noise(fre*p)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float fbmWrap(vec2 p){
  vec2 q = vec2(
                fbm(p+vec2(13.24,42.74)),
                fbm(p+vec2(51.16,17.93))
                );
  // float n = fbm(p);
  // vec2 q = vec2(n, n*33.22+11.45);

  float d = fbm(q);
  return d;
}

float fbmWrap(vec3 p){
  vec3 q = vec3(
                fbm(p+vec3(13.24,42.74,44.32)),
                fbm(p+vec3(51.16,17.93,98.23)),
                fbm(p+vec3(43.46,85.43,64.91))
                );
  // float n = fbm(p);
  // vec2 q = vec2(n, n*33.22+11.45);

  float d = fbm(q);
  return d;
}

float remap01(float v,float vmin,float vmax){
  return clamp(v-vmin,0.,1.)*(vmax-vmin);
}

struct Stop {
  vec3 col;
  float v;
};

vec3 col_gradient(float v){
  Stop s1 = Stop(vec3(1,0,0), .1);
  Stop s2 = Stop(vec3(0,1,0), .3);
  Stop s3 = Stop(vec3(0,0,1), .5);
  Stop s4 = Stop(vec3(1,1,1), 1.);
  Stop stops[4];
  stops[0] = s1;
  stops[1] = s2;
  stops[2] = s3;
  stops[3] = s4;

  vec3 col = s1.col;

  for(int i=0;i<4;i++){
    Stop ss = stops[i];
    Stop se = stops[i+1];
    if(v>ss.v){
      float v01 = (v-ss.v)/(se.v-ss.v);
      col = mix(ss.col, se.col, v01);
      break;
    }
  }

  return col;
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

  float n = noise(vec3(uv*1.4+vec2(T,0),T));
  vec2 uv2 = mix(uv, vec2(n), .2);


  float d = fbmWrap(vec3(uv2*vec2(.5)*vec2(1.,7.)+vec2(-T*.5,0), T*.5));

  // vec3 col = palette(d);
  vec3 col = s1(vec3(3,2,1)+d*10.);
  d -= uv.x-.6;

  col = pow(col+.6, vec3(2.1));

  O.rgb += d*col;
}