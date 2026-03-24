// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"


#define T iTime
#define PI 3.1415926
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
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
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

float noise2(vec2 uv){
  return texture(iChannel0, uv).r;
}


vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
float voronoi(vec2 uv, float seed){
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  vec2 min_d = vec2(1e10);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+seed)*.3+.3;
    float d1 = length(nei+pos-uvf);
    
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
    }else if(d1 < min_d.y){
      min_d.y = d1;
    }
  }
  }

  float edge = min_d.y-min_d.x;
  return edge;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdRoundedX( in vec2 p, in float w, in float r )
{
    p = abs(p);
    return length(p-min(p.x+p.y,w)*0.5) - r;
}
float map(vec2 uv){
  uv = fract(uv);
  uv -= .5;
  uv = abs(uv);
  uv *= rotate(T);

  // float d = length(uv) - .1;
  // float d = sdBox(uv, vec2(.1,.3));
  // float d = sdRoundedX(uv, .2, .1);
  float d = min(abs(uv.x),abs(uv.y));
  return d;
}

float fbm(vec2 uv){
  float fre = 1.;
  float amp = 1.;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    fre *= 2.;
    amp *= .5;
    n += voronoi(uv*fre, i+T*.2)*amp;
    // n += amp*map(uv*fre);
  }
  return n;
}

// https://iquilezles.org/articles/warp/
float pattern( in vec2 p, out vec2 r )
{
    vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                   fbm( p + vec2(5.2,1.3) ) );

    r = vec2( fbm( p + 4.0*q + vec2(1.7,9.2) ),
              fbm( p + 4.0*q + vec2(8.3,2.8) ) );

    return fbm( p + 4.0*r );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 col = vec3(0.);


  vec2 cr;
  float d = pattern(uv*.3, cr);
  float d_mouse = length(iMouse.xy);

  col += .2 * s1(vec3(3,2,1)+d_mouse*.1 + 10.*(cr.x+cr.y))/d;

  O.rgb = col;
}