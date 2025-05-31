#define T iTime
#define PI 3.141596

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


float fbm(vec2 p){
  float a = .5;
  float n = 0.;

  for(float i=0.;i<6.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;
  float a = atan(uv.y, abs(uv.x));
  float l = length(uv);
  vec2 uv_polar = vec2(a,l);

  float n = fbm(uv_polar*vec2(2.)-T*0.1);

  // 噪音扭曲uv-->扭曲的形状
  vec2 uv_abs = abs(uv);
  float d = length(uv_abs + noise(uv_abs*vec2(4,2)-T*vec2(0.1,0)))-0.3;

  // 噪音扭曲距离场
  n = n*smoothstep(0.,.3,l)*1.5;
  d += n;

  d = smoothstep(0.,0.15,d);
  O.rgb += d;

}