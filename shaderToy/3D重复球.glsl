#define T iTime
#define PI 3.141596
#define S smoothstep


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

  vec3 ro = vec3(0,0,-30);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d;
  vec4 U;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xy *= rotate(T*0.3);
    p.xz *= rotate(T*0.3);

    float n = 2.;

    vec3 q = p.xyz;
    vec3 id = round(q.xyz/n)*n;
    id = clamp(id, -10., 10.);
    q.xyz -= id;

    float r = sin(id.x+id.y+id.z+T*10.)*0.5+0.5;
    r = 0.1+r*.2;

    d = length(q.xyz)-r;
    z += d * 0.1;

    U += (1.1+sin(vec4(3,2,1,0)+(id.x+id.y+id.z)*0.1+T));
    // O.rgb += vec3(1,0,0)/d;
    O = U/d*U.w;
    if(z > 1e2 || d < 1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}