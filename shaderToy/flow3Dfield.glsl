#define T iTime
#define PI 3.141596
#define S smoothstep
#define sss(v) (sin(v*1.5+sin(v)*1.5)*.5+.5)



float fbm(vec2 p){
  float res = 0.;
  vec2 seed = vec2(0.02,0.04);
  for(float i=1.;i<5.;i*=1.42){
    res += abs(dot(cos(p * i-T + i), seed)) / i;
  }
  return res;
}



mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://iquilezles.org/articles/distfunctions/
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,12,0);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;


  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    vec3 q = p;
    q.yz *= rotate(.6);
    q.z += T*4.;

    float s = 1.;
    vec3 id = round(q/s);
    id.y = 0.;  // xz平面,不需要y重复,用三维去表示,是为了可读性和鸡尾酒适配

    float rar = 1.;
    float r = .1;

    int range = 1;
    for( int x=-range; x<=range; x++ ){
    for( int z=-range; z<=range; z++ ){
      vec3 rid = id;
      rid.x += float(x);
      rid.z += float(z);


      vec3 q2 = q-s*rid;

      float n = sss(rid.x*.1+rid.z*.2+T);
      float a = n*PI;
      float h = n*3.+1.;

      vec3 p1 = vec3(0);
      vec3 p2 = vec3(cos(a),0,sin(a))*rar;
      p2.y = h;

      float d1 = sdCapsule(q2, p1, p2, r);
      d = min(d, d1);
    }}

    float glow = sss(p.x*.4+p.y)*5.+2.;

    // d = abs(d)+0.01;
    d = max(0.01, d);
    O.rgb += (1.1+sin(vec3(3,2,1)+(id.z+id.x)*.05+T))/d*glow;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e5);
}