// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}
vec2 voronoi(vec2 uv, out vec2 oA, out vec2 oB){
  
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  // x分量代表当前像素距离特征点的最小距离,y代表次小距离
  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+sin(T*2.)*10.)*.3+.3;
    float d1 = length(nei+pos-uvf);
    /*
    距离小于最小距离,
    次小距离更新为现在的"最小距离"
    最小距离更新

    距离小于次小距离,
    次小距离更新
    */
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
      oA = pos;
    }else if(d1 < min_d.y){
      min_d.y = d1;
      oB = pos;
    }
  }
  }

  return min_d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 col = vec3(0);

  vec2 oA;
  vec2 oB;
  vec2 vor = voronoi(uv*rotate(.4)*vec2(1.5,1.)+vec2(mod(-T*4.,100.)), oA, oB);
  float edge = vor.y-vor.x;

  float n0 = noise(uv*1.4+vec2(mod(T*3.,100.)));

  float d = abs(uv.y+n0*.5);
  // d = pow(.1/d,2.);
  // d = clamp(d,0.,1.);
  float dd = 0.;
  // dd += S(.3,0., d)*.3;
  // dd += S(.1,0., d)*.2;
  // dd += S(.06,0.,d)*.2;
  // dd += S(.01,0.,d)*.1;
  dd += pow(.1/d, 2.);
  
  float n = pow(vor.x+.7, 5.);
  dd *= n;
  dd = pow(dd*1., 2.);
  vec3 c = s1(vec3(3,2,1)+uv.x);
  col += dd*c;

  col = tanh(col);

  O.rgb = col;

}