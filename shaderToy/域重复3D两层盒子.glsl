#define T iTime
#define PI 3.141596
#define S smoothstep
#define st(v) (sin(v*T)*.5+.5)

float hash21(vec2 p) {
  float x = dot(p, vec2(.4, .2));
  return abs(cos(x+sin(x*5.)/5.));
}

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p, float h, float s){
  p = abs(p)-vec3(s,h,s);
  float d = max(p.x,max(p.y,p.z));
  d = max(0.01, d);
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
    // p.xy *= rotate(T);
    p.xz *= rotate(T*.1);
    p.z += T;

    vec3 q = p;
    if(q.y<0.){
      q.x += 43.;
    }
    q.y = abs(q.y);
    q.y -= 10.;

    // domainrepetition https://iquilezles.org/articles/sdfrepetition/
    float s = 2.;
    vec2 id = round(q.xz/s);
    vec2  o = sign(q.xz-s*id);
    for( int x=0; x<2; x++ ){
    for( int y=0; y<2; y++ ){
      vec2 rid = id + vec2(x,y)*o;
      vec3 r = q;
      r.xz -= s*rid;
      float n = hash21(rid*(st(.1)*.1+.5)+T*.5);
      float h = n*4.+2.;
      float s = n*.5+.2;

      d = min( d, map(r, h, s));
    }}

    d = max(0.01,d);

    O.rgb += (1.1+sin(vec3(3,2,1)+(id.x+id.y)*.4))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}