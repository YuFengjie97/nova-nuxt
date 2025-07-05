#define T iTime
#define PI 3.141596
#define S smoothstep


vec4 map(vec3 p) {
  vec3 col = vec3(0);
  float d = 0.;
  return vec4(col, d);
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p, vec3 seed){
  float res = 0.;
  for(float i=1.;i<8.;i*=1.42){
    res += abs(dot(cos(p * i), seed)) / i;
  }
  return res;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-20.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;


  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.xy *= rotate(T*.3);
    p.xz *= rotate(T*.3);

    float n = fbm(p,vec3(.04));
    float d = length(p)-10.;
    d -= n*3.;
    // d = max(0.01,d*.3);
    d = max(0.01,abs(d)*.3+.01);

    O.rgb += (1.1+sin(vec3(3,2,1)+(p.x+p.y)*.2))/d;
    z += d;

    if(z>20. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 5e3);
}