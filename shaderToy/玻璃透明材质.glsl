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

vec3 path(float t){
  // return vec3(
  //   cos(t+sin(t))*2.,
  //   sin(t+cos(t))*2.,
  //   t
  // );

  float v = t;
  return vec3(cos(v*.2+sin(v*.1)*2.)*3.,
              sin(v*.2+cos(v*.3)   )*3., v);
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	// vec3 cw = normalize(ta-ro);            // 相机前
	// vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	// vec3 cu = normalize( cross(cw,cp) );   // 相机右
	// vec3 cv = normalize( cross(cu,cw) );   // 相机上
  // return mat3( cu, cv, cw );

  vec3 front = normalize(ta - ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  return mat3(right, up, front);
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float map(vec3 p){
  p.xz *= rotate(T*.5);
  p.yz *= rotate(T*.5);

  float d = sdBoxFrame(p, vec3(4), .6);
  // float d = sdBox(p, vec3(4));
  // float d = length(p) - 4.;
  {
    // vec3 q = p*1.;
    // float d1 = dot(sin(q), cos(q.zxy));
    // d = max(d, d1*.7);
  }

  d = abs(d)*.4 + .01;
  return d;
}



float rayMarch(vec3 ro, vec3 rd, float offset){
  float i=0.;
  float z = 0.;
  vec3 p;
  float acc = 0.;
  while(i++<80.){
    p = ro+rd*z;

    float d = map(p);

    acc += 1./d * s1(i*.3 + offset);
    z+=d;
  }
  return acc;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  mat2 mx = rotate(m.x*iMouse.z + T*(1.-iMouse.z));
  mat2 my = rotate(m.y*iMouse.z + T*(1.-iMouse.z));

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-10);
  vec3 tar = vec3(0);
  vec3 rd = setCamera(ro, tar, 0.) * normalize(vec3(uv, 1.));


  vec3 col = vec3(0);
  float i = 0.;

  col.r = rayMarch(ro, rd, .1 * 10.);
  col.g = rayMarch(ro, rd, .2 * 10.);
  col.b = rayMarch(ro, rd, .3 * 10.);
  
  col = tanh(col/1e3);
  

  O.rgb = col;
}