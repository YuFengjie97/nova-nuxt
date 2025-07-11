#define T iTime
#define PI 3.141596


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
    p += sin(p.zxy * freq  + T*0.05) / freq;
    freq *= 2.;
  }
  d =  abs(length(p.xy)-9.) / 30.;

  return d;

}

// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ) + 
					  e.yyx*map( pos + e.yyx*eps ) + 
					  e.yxy*map( pos + e.yxy*eps ) + 
					  e.xxx*map( pos + e.xxx*eps ) );
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


  vec3 light = normalize(vec3(1,1,p.z)-p);
  vec3 nor = calcNormal4(p);
  float dif = clamp(dot(light, nor), 0., 1.);
  // float dif = dot(light, nor);
  
  O.rgb = sin(vec3(3,2,1)+d*30.+p.z*0.1);
  O.rgb += dif*dif*vec3(1,1,0)*0.8;
  //O.rgb = tanh(O.rgb * 0.9);
}