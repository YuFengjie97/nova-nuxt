// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"


#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
#define P(z) vec3(cos((z)*.1)*4.,sin((z)*.1)*4.,(z))
#define t_path T*5.

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


// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );

  // vec3 front = normalize(ta - ro);
  // vec3 up = vec3(0,1,0);
  // vec3 right = normalize(cross(front, up));
  // return mat3(right, up, front);
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

float noise(vec3 p){
  // p*=vec3(.1,.1,2.2);
  // float n1 = dot(cos(p+tanh(p*10.)), vec3(.1));
  float n1 = dot(cos(p+sin(p*.3)*.5), vec3(.1));
  float n2 = dot(cos(p), vec3(.1));
  return mix(n1,n2,s1(T));
}

vec3 C = vec3(10,2,1);
vec3 RO;
float fbm(vec3 p){
  float amp = 1.;
  float n = 0.;

  for(float i=0.;i<4.;i++){
    p.xz *= rotate(.2);
    p += sin(p.zxy+T*i*2.)*amp;
    n += abs(noise(p))*amp;
    amp *= .5;
    p *= 2.;
    C += amp*.1;
  }
  return n;
}

vec3 col = vec3(0);
float map(vec3 p){

  float d = fbm(p);
  float d1 = length(p - RO)-4.;
  d = max(d, -d1);
  col += s1(C+T)/(max(d, .01));

  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = P(t_path);
  RO = ro;
  vec3 rd = setCamera(ro, P(t_path+1.), s1(T*.5)) * normalize(vec3(uv, 1.));

  float z = .1;

  float i=0.;
  while(i++<80.){
    vec3 p = ro + rd * z;

    float d = map(p);
    z += d;
  }


  O.rgb += col;
  O.rgb = tanh(O.rgb/1e3);
}