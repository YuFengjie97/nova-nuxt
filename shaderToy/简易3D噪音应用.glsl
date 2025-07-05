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
  for(float i=1.;i<4.;i++){
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

    float r = abs(dot(cos(p*2.+cos(p*4.)+2.6)*1.+1., vec3(3.1,3.2,3.3)))*.5+.5;
    float d = length(p)-r;
    d = max(0.01,d*.1);

    O.rgb += (1.1+sin(vec3(3,2,1)+dot(p,p)*.05-T))/d;
    z += d;

    if(z>20. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}