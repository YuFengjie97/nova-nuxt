#define T iTime
#define PI 3.141596
#define S smoothstep

float hash21(vec2 p) {
    // p = fract(p * vec2(3.34, 5.21));
    // p += dot(p, p + 5.32);
    // return fract(sin(dot(p, vec2(2.98, 7.23))) * 4.3);
  return abs(cos(dot(p, vec2(3.4, 7.5))));
}

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

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    // p.xz *= rotate(T);
    // p.xy *= rotate(T);
    p.z += T;
    vec3 q = p;

    float s = 2.2;
    vec2 id = round(q.xz/s);
    q.xz -= s*id;
    
    q.y = abs(q.y);
    q.y -= 10.;

    float h = hash21(id+T*1e-1)*2.+1.;
    q = abs(q)-vec3(1,h,1);
    d = max(q.x,max(q.y,q.z));
    d = max(0.01, d);

    O.rgb += (1.1+sin(vec3(3,2,1)+(id.x+id.y)))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}