#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float remap01(float v, float a, float b){
  return (v-a)/(b-a);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,0);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float D=1e6;
  vec4 U;

  float st = sin(T*0.1)*0.5+0.5;
  ro.z += T*10.;

  for(float i =0.;i<60.;i++){
    vec3 p = ro + rd * z;

    // p.y += sin(p.x*5.)/5.;

    // float amp = 2.;
    // float freq = 1.;
    // for(float x=0.;x<4.;x++) {
    //   p += amp*sin(p.x);
    //   p *= freq;
    //   amp *= 0.5;
    // }

    vec3 q = p.xyz;
    float rep = round(q.z/2.)*2.;
    float id = floor(rep);
    q.z -= rep;

    q.xy *= rotate(id*0.1);
    q.y -= 10.;

    float d = length(q.yz)-.6;
    d = max(d, 1e-1);
    D = min(D, d);

    U += 1.1 + sin(vec4(3,2,1,0)+(p.x+p.z)*0.1-T*4.);

    z += d*0.2;
    O += U/d*U.w;

    if(z > 1e2 || d < 1e-3) break;
  }
  O = tanh(O / 5e5);
}