#define PI 3.141596
#define T iTime

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// xor turbulence fbm
vec3 turbulence(vec3 p){
  float freq = 0.5;
  float amp = 2.;
  for(float i=0.;i<4.;i++){
    p += amp * sin(p*freq);
    freq *= 2.;
    amp *= 0.5;
  }
  return p;
}

float map(vec3 p){
  // length(p.xy)是通向z轴的圆柱体,取负值,反转sdf,相当于跑到圆柱体内部了, +值 是半径
  float d1 = abs(-length(p.xy) + .3);
  return d1;
}

#define ZERO min(iFrame,0)
vec3 calcNormal(vec3 pos){
  vec3 n = vec3(0.0);
  for( int i=ZERO; i<4; i++ )
  {
      vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
      n += e*map(pos+0.0005*e);
  }
  return normalize(n);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;
  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-1.);
  vec3 rd = normalize(vec3(uv,1.));

  float z = 0.;
  float d = 0.;
  vec3 p;

  for(float i=0.;i<1e3;i++){
    p = ro + rd * z;
    // vec3 toCenter = vec3(p.xy, 0);
    // p.xyz += toCenter * sin(p.z+cos(p.z))*0.1;

    if(iMouse.z > 0.) {
      p.xz *= rotate(-m.x * PI * 2.);
      p.yz *= rotate(-m.y * PI * 2.);
    }

    d = map(p);
    z += d;

    if(z > 1e2 || d < 1e-2) break;
  }
  vec3 col = sin(vec3(3,2,1) + d * 10.);
  d = pow(.1/d, 2.);
  
  O.rgb += col*d * 0.01;
}