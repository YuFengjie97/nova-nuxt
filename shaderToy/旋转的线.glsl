#define T iTime
#define PI 3.141596


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://iquilezles.org/articles/smin/
float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    return max(k,min(a,b)) -
           length(max(k-vec2(a,b),0.0));
}


vec4 map(vec3 p){
  vec3 col = vec3(0);

  p.z += T*2.;
  float t = sin(T)*0.5+0.5;
  float a =  .1*p.z;
  mat2 R = rotate(a);
  p.xy *= R;

  p = mod(p,5.)-2.5;
  float d = length(p.xy)-0.9;
  d = abs(d);

  float d1 = 1e5;
  for(float i=1.;i<4.;i++){
    p.xy = abs(p.xz)*rotate(0.2*i)-i*0.13;
    float d2 = length(p.xy) - .06;
    d2 *= 0.2;
    d1 = min(d1, d2);
    col+=d2*i;
  }
  d = smin(d, d1, 0.3);
  return vec4(col, d);
  // return abs(d)+0.01;
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
        n += e*map(p+e*h).w;
    }
    return normalize(n);
}

vec3 rayMarch(vec3 ro, vec3 rd){
  vec3 p;
  float z;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    float d = map(p).w;
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

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));
  vec3 p = rayMarch(ro, rd);
  vec4 M = map(p);
  O.rgb += sin(vec3(3,2,1)+M.rgb);
}