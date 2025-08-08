// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

/**
2d plane domainrepetition https://www.shadertoy.com/view/XtSczV
sdf https://iquilezles.org/articles/distfunctions/
*/

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec2 rep(vec2 p, float n){
  float a = atan(p.y, p.x);
  float s = TAU / n;
  float id = round(a / s);
  float b = s * id;
  p.xy = rotate(b)*p.xy;
  return p.xy;
}

float sdRing(vec3 p, float r, float thick){
  return length(vec2(length(p.xy) - r, p.z)) - thick;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * 5.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }else{
      p.yz *= rotate(T);
      p.xz *= rotate(T);
    }

    float n = 8.;
    float d = 1e4;
    float r = 5.;
    float thick = .1;
    {
      vec3 q = p;
      q.xz = rep(q.xz, n);
      float d1 = sdRing(q, r, thick);
      d = min(d, d1);
    }
    {
      vec3 q = p;
      q.yz = rep(q.yz, n);
      float d1 = sdRing(q, r, thick);
      d = min(d, d1);
    }
    {
      vec3 q = p;
      q.xy = rep(q.xy, n);
      float d1 = sdRing(q.xzy, r, thick);
      d = min(d, d1);
    }

    d = max(0., d);
    col += (1.1+sin(vec3(3,2,1)+p.y+p.x))/d;
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e2);

  O.rgb = col;
}