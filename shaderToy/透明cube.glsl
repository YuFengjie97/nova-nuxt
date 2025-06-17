#define T iTime
#define PI 3.141596

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


// Box - exact   (Youtube Tutorial with derivation: https://www.youtube.com/watch?v=62-pRVZuS5c)
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p){
  vec2 m = iMouse.xy;

  if(iMouse.z>0.){
    p.xz *= rotate(m.x);
    p.yz *= rotate(m.y);
  }

  float d = sdBox(p, vec3(0.5));
  // d = abs(d)+0.01;
  return abs(d)+0.01;
}


// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal4( in vec3 p ) // for function f(p)
{
    const float h = 0.01;      // replace by an appropriate value
    #define ZERO (min(iFrame,0)) // non-constant zero
    vec3 n = vec3(0.0);
    for( int i=ZERO; i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e*map(p+e*h);
    }
    return normalize(n);
}

vec3 rayMarch(vec3 ro, vec3 rd){
  vec3 p;
  float z;


  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    
    float d = map(p);
    z += d;

    if(z>100. || d<1e-2) break;
  }
  return p;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;


  vec3 ro = vec3(0.,0.,-2.);
  vec3 rd = normalize(vec3(uv, 1.));

  vec3 p = rayMarch(ro, rd);
  float d = map(p);

  vec3 nor = calcNormal4(p);
  vec3 lig = vec3(1,1,-1)-p;
  float dif = clamp(dot(lig, nor),0.,1.);

  if(d < .2) {
    O.rgb = sin(vec3(3,2,1)+d+p.x*2.);
    // O.rgb += dif*vec3(1,0,0);
  }
}