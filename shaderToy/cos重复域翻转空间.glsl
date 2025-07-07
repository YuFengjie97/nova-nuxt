#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://iquilezles.org/articles/distfunctions/
float sdOctahedron( vec3 p, float s)
{
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57735027;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-8.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;


  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    vec3 q = p;

    p.xz *= rotate(T*.5);

    // Apply "inversion" transformation aka @mla inversion
    p *= max(0.5, 6./dot(p,p));

    // repetition
    float scale = 3.;
    float range = 2.;
    float unit = PI/scale/2.;
    p.xz = clamp(p.xz, -PI/scale*range, PI/scale*range);
    p.xz = cos(p.xz*scale)/scale;
    d = length(p.xz)-unit*.25;

    // 中间看起来比较空,随便加点东西
    float d1 = length(q)-.8;
    d = min(d,d1);

    d = max(0.01,d);

    O.rgb += (1.1+sin(vec3(3,2,1) + (p.x+p.y)*.7))/d;

    z += d;

    if(z>20. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 7e3);
}