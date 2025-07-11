#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdRing(vec3 p, float r, float rr){
  float d = length(vec2(length(p.xz)-r, p.y))-rr;
  return d;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.yz *= rotate(T*.4);

    vec3 q = p;
    float s = .4;
    float id = (round(length(q.xz)/s));
    id = clamp(id, 1., 10.);
    q.y -= sin(id+T*3.);
    float d1 = sdRing(q, id*s, .02);
    d = min(d, d1);

    d = max(0.01,d);

    O.rgb += (1.1+sin(vec3(3,2,1)+id))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}