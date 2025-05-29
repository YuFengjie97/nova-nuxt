#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define PI 3.141596
#define T iTime


vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}
float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2
    const float K2 = 0.211324865; // (3-sqrt(3))/6

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a,a), dot(b,b), dot(c,c)), 0.0);

    vec3 n = h * h * h * h * vec3(
        dot(a, hash(i + 0.0)),
        dot(b, hash(i + o)),
        dot(c, hash(i + 1.0))
    );

    return dot(n, vec3(70.0));
}





mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

float fbm(vec2 p){
  float a = .5;
  float n = 0.;

  for(float i=0.;i<4.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}

// use: float d = star(uv, -7., 1.);
// float star(vec2 p, float k, float b){
//   p = abs(p);
//   float d1 = p.y - (k*   p.x+b);
//   float d2 = p.y - (1./k*p.x-b/k);
//   d1 = min(d1, d2);
//   return d1;
// }

float star(vec2 p, float r) {
    p = abs(p);
    float angle = radians(5.);
    vec2 dir1 = vec2(cos(angle), sin(angle));     // 第一条斜线方向
    vec2 dir2 = vec2(cos(PI/2.-angle), sin(PI/2.-angle));   // 第二条斜线方向

    float d1 = dot(p, dir1) - r;
    float d2 = dot(p, dir2) - r;
    return min(d1, d2);
}

float glow(float d, float r, float ins){
  return pow(r/d,ins);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  // O.rgb *= 0.;
  O.a = 1.;


  vec2 scale = vec2(10.);
  // vec2 offset = mod(vec2(T),60.);
  mat2 rot = rotate(T*0.1);
  float n = fbm(uv*scale*rot);
  mat2 rot2 = rotate(-T*0.1);
  float n2 = fbm(uv*scale*rot2);
  n = (n+n2)/2.;

  uv += n*0.2;

  float d = star(uv, 0.01);
  d = smoothstep(.11,.1,abs(d));
  // d = glow(d,.1,2.);



  O.rgb += d;
}