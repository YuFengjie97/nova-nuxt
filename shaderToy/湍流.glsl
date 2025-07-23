#define PI 3.141596
#define T iTime


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float map(vec3 p){
  float d;
  float freq = .5;

  // xor https://mini.gmshaders.com/p/turbulence
  for(float i=1.;i<6.;i*=1.5){
    p += sin(p.zxy * freq  + T*0.1) / freq;
    freq *= 2.;
  }
  d =  abs(length(p.xy)-9.) / 30.;
  return d;

  // float d  =length(p) - 0.5;
  // return d;
}

// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal(vec3 p){
  vec2 e = vec2(0.01,0);

  vec3 g = vec3(
    map(p+e.xyy)-map(p-e.xyy),
    map(p+e.yxy)-map(p-e.yxy),
    map(p+e.yyx)-map(p-e.yyx)
  );
  return g;
}


// 特殊情况map(p-e)情况=0时,可以用, 普通情况,错误值
vec3 calcNormal2(vec3 p){
  vec2 e = vec2(0.01,0);

  vec3 g = vec3(
    map(p+e.xyy),
    map(p+e.yxy),
    map(p+e.yyx)
  );
  return g;
}

vec3 calcNormal3( in vec3 p) // for function f(p)
{
    const float h = 0.01; // replace by an appropriate value
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy*map( p + k.xyy*h ) + 
                      k.yyx*map( p + k.yyx*h ) + 
                      k.yxy*map( p + k.yxy*h ) + 
                      k.xxx*map( p + k.xxx*h ) );
}
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
    p.z += T;
    
    float d = map(p);
    z += d;

    if(z>50. || d<1e-2) break;
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
  float d = map(p);
  // O.rgb += d;


  vec3 light = normalize(vec3(1,1,-2)-p);
  vec3 nor = calcNormal4(p);
  float dif = clamp(dot(light, nor), 0., 1.);
  
  O.rgb = sin(vec3(3,2,1)+d*30.+p.z*0.1);
  O.rgb += dif*dif*vec3(0.5,0.5,0);
}