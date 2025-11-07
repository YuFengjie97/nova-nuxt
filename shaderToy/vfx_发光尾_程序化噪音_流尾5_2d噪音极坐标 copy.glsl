// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256_rgb.png"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/texture/vfx_tail/tail_2.png"

// #define T sin(iTime*0.1)/0.1
#define T mod(iTime,10.)
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
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);

  // vec3 a = vec3(0.5, 0.5, 0.5);
  // vec3 b = vec3(0.5, 0.5, 0.5);
  // vec3 c = vec3(2.0, 1.0, 0.0);
  // vec3 d = vec3(0.5, 0.2, 0.25);
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


  // 4个顶点的随机值也要进行mod取余重复
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


// David Hoskins hash function
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}


vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

float voronoise( in vec2 uv)
{
	vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);

  float d = 1e4;

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = hash22(uvi+nei);
    float d1 = length(nei+pos-uvf);
    d = min(d, d1);
  }
  }

  return d;
}

vec3 C = vec3(3,2,1);
float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  float fre = 1.;
  for(float i =0.;i<6.;i++){
    // n += voronoise(p*fre)*amp;
    n += noise(p*fre)*amp;
    amp *= .5;
    fre *= 1.3;
    C += n;
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

float remap01(float v, float vmin, float vmax){
  return clamp(max(0.,v-vmin)/(vmax-vmin),0.,1.);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-vec2(R.x/2.,R.y/2.))/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  uv *= 2.;

  float sca = 4.;
  float speed = 1.;

  float len = length(uv);
  // len = log(len);
  len *= .5;

  vec2 uv2 = vec2((atan(uv.y,uv.x)+PI)/TAU, len);
  float range = S(0.,0.1,uv2.x) * S(1.,.9,uv2.x);
  uv2 *= sca;
  float d1 = fbmWrap(uv2+vec2(0., -T*speed));
  d1 *= range;

  float d2 = 0.;
  {
    vec2 uv2 = vec2((atan(uv.y,-uv.x)+PI)/TAU, len);
    float range = S(0.,.1,uv2.x)*S(1.,.9,uv2.x);
    uv2 *= sca;
    d2 = fbmWrap(uv2+vec2(.4,.5)+vec2(0., -T*speed));
    d2 *= range;
  }

  float d = max(d1, d2);

  vec3 col = s1(vec3(3,2,1)+d*10.);
  col *= 3.; // 这算是自发光吗?


  O.rgb += d*col;
}