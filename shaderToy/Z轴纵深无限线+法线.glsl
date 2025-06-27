#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec4 map(vec3 p){
  vec3 q = p.xyz;
  float rep = round(q.z/5.)*5.;
  float id = floor(rep);
  q.z -= rep;

  q.xy *= rotate(id*0.03);
  q.y += 5.;

  float d = length(q.yz)-.5;

  d = max(d, 1e-4);
  vec3 col = sin(vec3(3,2,1)+id*0.1);

  if(d > 1e-3) {
    col = vec3(0);
  }
  return vec4(col, d);
}

vec3 calcNormal(vec3 p){
  vec2 e = vec2(0.01,0);

  vec3 g = vec3(
    map(p+e.xyy).w-map(p-e.xyy).w,
    map(p+e.yxy).w-map(p-e.yxy).w,
    map(p+e.yyx).w-map(p-e.yyx).w
  );
  return normalize(g);
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-5);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d=1e6;
  vec4 U;

  float st = sin(T*0.1)*0.5+0.5;
  vec3 p;

  vec3 col;
  for(float i =0.;i<100.;i++){
    p = ro + rd * z;
    p.z += T*2.;

    vec4 M = map(p);
    float d = M.w;
    col = M.rgb;

    z += d + 1e-3;
    if(z > 1e2 || d < 1e-3) break;
  }
  vec3 nor = calcNormal(p);
  {
    vec3 amb = vec3(0,0,1.);
    float dif = dot(amb, nor)*0.5+0.5;
    O.rgb = col * dif;
  }
  {
    vec3 light = normalize(vec3(0,0,p.z-10.)-p);
    float dif = clamp(dot(light, nor), 0., 1.);
    O.rgb += col * dif*dif;
  }

  // O = tanh(O / 1e5);
}