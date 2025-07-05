#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// this noise trick is from diatribes https://www.shadertoy.com/view/w3tGWS
float fbm(vec3 p, vec3 seed){
  float res = 0.;
  for(float i=1.;i<8.;i*=1.42){
    res += abs(dot(cos(p * i), seed)) / i;
  }
  return res;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-15.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= rotate(p.y*0.2);
    p.y += T*2.;

    vec3 q = p, q2 = p;

    // 中间的横向线
    float s = 1.;
    float id = round(q.y/s);
    q.y -= s*id;
    float d1 = length(q.yz)-.2;

    // 圆柱来限制范围
    float r = 3.;
    float d2 = length(p.xz)-r;
    d = max(d1, d2);
    d = max(0.01, d);
    O.rgb += (1.1+sin(vec3(3,2,1)+p.y))/d;

    // 两侧竖直的线
    q2.x = abs(q2.x);
    float d3 = length(q2.xz-vec2(r+.4,0))-.4;
    d3 = max(0.01, d3*.8);
    d = min(d, d3);
    O.rgb += (1.1+sin(vec3(3,2,1)+q2.y*.2))/d3;


    z += d;
    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}