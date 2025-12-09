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

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise(float v){
  float i = floor(v);
  float f = fract(v);
  float h1 = hash11(i);
  float h2 = hash11(i+1.);
  return mix(h1,h2,f);
}


float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i=0.;i<5.;i++){
    n += amp*abs(dot(cos(p*fre), vec3(.06)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

vec3 path(float t){
  vec3 p = vec3(
    cos(t*.3)*4.,
    sin(t*.3)*4.,
    t
  );
  float nt = noise(t);
  p += cos(p.zxy + nt*6.)*.4;

  return p;
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

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  // float t_path = mod(T*2., 60.);
  float t_path = T*1.2;
  vec3 ro = path(t_path);
  vec3 tar = path(t_path + 3.);

  vec3 rd = setCamera(ro, tar, 0.) * normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  mat2 mx = rotate(T*0.);
  mat2 my = rotate(T*0.);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }

  float nt = noise(T+2.);

  vec3 col = vec3(0);
  float i = 0.;
  while(i++<80.){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;



    float d;
    {
      vec3 q = p;
      q += cos(q.zxy*.2+nt*2.)*4.;
      q.z += T*20.;

      d = length(cos(q*.3)/.3)-.1;
      d = max(d*.3, 0.01);
    }
    {
      vec3 q = p;
      float d1 = length(q.xy-path(p.z).xy)-3.;
      d1 = abs(d1);

      q.xz *= rotate(i);
      q.yz *= rotate(i+T*.001);
      d1 += fbm(q*2.);

      d1 = max(d1*.3, 0.01);
      d = min(d, d1);
    }
    
    col += s1(vec3(3,2,1)+dot(p, vec3(.1))) / d;

    z += d;
  }

  col = tanh(col / 1e3);

  O.rgb = col;
}