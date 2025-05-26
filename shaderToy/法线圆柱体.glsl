#define PI 3.141596
#define T iTime

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec4 map(vec3 p){
  float d1 = length(p.xz) - .1;
  float d2 = p.y + 0.1;
  d1 = max(d1, -d2);
  d2 = -p.y + 0.2;
  d1 = max(d1, -d2);
  return vec4(d1, p);
}

#define ZERO min(iFrame,0)
vec3 calcNormal(vec3 pos){
  vec3 n = vec3(0.0);
  for( int i=ZERO; i<4; i++ )
  {
      vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
      n += e*map(pos+0.0005*e).x;
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
  for(float i=0.;i<1e3;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z > 0.) {
      p.xz *= rotate(-m.x * PI * 2.);
      p.yz *= rotate(-m.y * PI * 2.);
    }


    d = map(p).x;
    z += d;

    if (d < 1e-3) {
      vec3 nor = calcNormal(p);
      O.rgb = nor * 0.5 + 0.5;
      break;
    }

    if(z > 1e3) {
      break;
    }
  }
}