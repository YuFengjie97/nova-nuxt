// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
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

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,1.,-0.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  vec3 p;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    p.z += T*2.;
    p.xy *= rotate(p.z*.1);
    p.y = -abs(p.y)+10.;
    float d0 = abs(p.y)*.1;
    d0 = abs(d0)+.1;

    vec3 q = p;
    float s = 2.;
    vec2 id = round(q.xz/s);
    q.xz -= id*s;
    float d1 = sdRoundBox(q, vec3(.8, .2, .8), .1);
    d1 = max(0.01, d1*.3);
    float d = min(d0, d1);

    d = d * (1.-hash12(uv.xy*30.+T)*.1);  // 使用噪点消除伪影

    float n = hash12(id+T*3e-4);
    float glow = n >.5 ? (n*2.) : 0.;

    col += glow*(.5+.5*sin(vec3(3,2,1)+id.x+id.y))/d0;
    // col += glow*(vec3(0,2,0))/d0;

    if(d<EPSILON || z>zMax) break;
    z += d;
  }
  col = tanh(col / 1e2);
  col *= exp(-3e-5*z*z*z);

  O.rgb = col;
}