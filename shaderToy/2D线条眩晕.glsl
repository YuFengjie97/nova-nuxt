#define S smoothstep
#define PI 3.141596
#define T iTime


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;
  vec2 p = uv;

  float st = sin(T)*0.5+0.5;
  st = 0.5+0.1*st;

  float total = 40.;
  for(float i = 1.;i<total;i++){
    float s = i / total;

    p *= rotate(s + T*0.1/i);
    p.x -= sin(i+3.+T)*s*0.1;
    float d1 = abs(p.y+sin(p.x*25.*st+T));
    float d2 = abs(p.y+cos(p.x*25.*st-T));
    float d = mix(d1, d2, st);
    d = pow(0.1/d, 2.);

    vec3 col = s*(1.1+sin(vec3(3,2,1)+i+p.x*10.));
    O.rgb += col*d;
  }
  // O.rgb = tanh(O.rgb / 1e1);
  O.rgb = 1.-exp(-O.rgb);
}