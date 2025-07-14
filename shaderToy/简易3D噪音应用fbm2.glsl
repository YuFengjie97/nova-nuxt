#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// // this noise trick is from diatribes https://www.shadertoy.com/view/w3tGWS
float fbm(vec3 p, vec3 seed){
  float res = 0.;
  for(float i=1.;i<8.;i*=1.42){
    res += abs(dot(cos(p * i-T + i), seed)) / i;
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

    float n = fbm(p*.9,vec3(.05));
    float d = length(p)-10.;
    d -= clamp(0.,10.,n*6.);
    // d = max(0.01,abs(d*.6)+.1);
    d = max(0.01,d*.6);

    O.rgb += (1.1+sin(vec3(1,2,3)+n*20.))/d*n*3.;
    z += d;

    if(z>40. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}