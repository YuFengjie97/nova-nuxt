#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/vfx_tail/buffer_voronoi.glsl"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-6;


vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}

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
  return vec2(cos(a), sin(a));
}

float noise2(vec2 p){
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

float noise(vec2 p){
  return texture(iChannel0, p).x;
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

vec2 hash21(float p)
{
	vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}


float d_circles(vec2 p, vec2 edg_min, vec2 edg_max){
  float N = 10.;

  float d = 1e10;
  for(float i=0.;i<N;i++){
    vec2 n = hash21(i);
    float x = (edg_max.x - edg_min.x) * n.x + edg_min.x;
    float y = (edg_max.y - edg_min.y) * n.y + edg_min.y;
    vec2 pos = vec2(x,y);
    float r = hash11(i*13.12);
    vec2 s = hash21(i*33.12)*2.;

    float d1 = length(p*s*rotate(r*6.)-pos) - r*.1;
    d = min(d, d1);
  }

  d = S(.01,0.,d);

  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 col = vec3(0);

  float n = noise(uv*.01+vec2(.01,0));
  float d = S(.55,.5,abs(uv.y*2.+n-.5));

  float d1 = d_circles(uv, vec2(-.5,0.), vec2(.5,.2));
  // d = max(d, -d1);
  // d = d - d1;
  d = d1;

  // d = 1.-S(0.1,0.,d);

  col += d;

  O.rgb = col;
}