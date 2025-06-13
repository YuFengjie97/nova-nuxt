#define PI 3.141596
#define T iTime

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


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

float map(vec3 p){
  p.xy += cos(p.yx*2.+T*2.)*.3;

  float d = length(p)-0.5;
  return d;
}

float getLight(vec3 p){
  vec3 light1 = normalize(vec3(sin(T),1,-2)   - p);
  // vec3 light2 = normalize(vec3(1,-1,-2) - p);
  vec2 e = vec2(0.01,0);
  vec3 g = normalize(vec3(
    map(p+e.xyy)-map(p-e.xyy),
    map(p+e.yxy)-map(p-e.yxy),
    map(p+e.yyx)-map(p-e.yyx)
  ));
  float lightDif = clamp(dot(light1, g),0.,1.);
  // lightDif += clamp(dot(light2, g),0.,1.)*0.5;
  return lightDif;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-1);
  vec3 rd = normalize(vec3(uv, 1.));
  float d = 0.;
  float z = 0.;
  vec3 p;

  for(float i=1.;i<60.;i++){
    p = ro + rd * z;

    if(iMouse.z > 0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float d = map(p);
    float dif = getLight(p);

    z += d;
    O.rgb = sin(vec3(3,2,1)+cos(p.x)*40.)*0.1;

    O.rgb += dif * dif * vec3(1);
    
    if(d<1e-4) break;
  }
}