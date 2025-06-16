#define PI 3.141596
#define T iTime

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
  // p *= 6./dot(p,p);
  vec3 p0 = p - round(p/5.)*5.;
  vec3 p1 = mod(p, 5.) - 2.5;
  vec3 p2 = cos(p);

  float t = sin(T)*0.5+0.5;
  // p = mix(p0, p1, t);
  // p = p1;

  mat2 R = rotate(T);

  float d = length(p.xz)-1.5;
  for(float i=1.;i<6.;i++){
    p.xz *= R;
    float dd = length(p.xz);
    d = min(d, dd);
  }

  return d;
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

  vec3 ro = vec3(0.,0.,-10.);
  // ro.yz += T;
  
  vec3 rd = normalize(vec3(uv, 1.));
  vec3 p = rayMarch(ro, rd);
  float d = map(p);
  float z = length(p);

  if(d < 0.1) {
    // vec3 light = normalize(vec3(0,0,ro.z));
    // vec3 nor = calcNormal4(p);
    // float dif = clamp(dot(light, nor), 0., 1.);
    // O.rgb = nor;
    // O.rgb = dif*dif*vec3(1,0,0);

    // O.rgb = sin(vec3(3,2,1)+p.z);
    // float amb = dot(nor, vec3(0,-4,0));
    // O.rgb += amb * vec3(.5);
    O.rgb = sin(vec3(3,2,1)+d*10.);
  }
}