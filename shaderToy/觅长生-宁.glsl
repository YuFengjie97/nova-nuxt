// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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

float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,15,-10);
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  mat2 mx = rotate(T*0.);
  mat2 my = rotate(T*0.);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }


  vec3 col = vec3(0);
  float i = 0.;
  vec3 C = vec3(3,2,1);
  while(i++<80.){
    vec3 p = ro + rd * z;
    vec3 p0 = p;

    p.xz *= mx;
    p.yz *= my;


    float d;
    {
      vec3 q = p;
      q.xz *= rotate(.3+T*.1);
      q.yz *= rotate(.1);
      vec3 q0 = q;

      float dis = length(q);
      q.y -= dis*.6;
      

      float ang = atan(q.z, q.x);
      dis = length(q)-T*2.5;
      dis = cos(dis*.5);

      ang = cos(ang*5.);

      vec3 q2 = vec3(ang, q.y, dis);
      q2 += cos(q2.zxy*2.+T*1.3)*.4;
      q2 += cos(q2.zxy*4.)*.1;
      q2 += cos(q2.zxy*8.-T)*.1;

      C += dot(cos(q2.xz), sin(q2.zx*.08));
      // C += dot(cos(q2), vec3(.1));
      // d = length(q2)-.1;
      d = sdBox(q2, vec3(.5,.5,.5));

      d += (dot(cos(q2*2.), sin(q2.yzx*2.)))*.2;
      d += (dot(cos(q2*4.), sin(q2.yzx*4.)))*.2;
      d += (dot(cos(q2*8.), sin(q2.yzx*8.)))*.2;

      {
        // 柱子
        float d1 = length(q0.xz) - 1.;
        d = smin(d, d1, 1.);
      }

      {
        // 防止遮挡
        float d1 = length(p0 - ro) - 3.;
        d = max(d, -d1);
      }
    }
    d = abs(d)*.4 + .01;
    
    
    col += s1(C) / d;

    z += d;
  }

  col = tanh(col / 8e2);

  O.rgb = col;
}