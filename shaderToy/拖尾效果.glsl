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

  for(float i=0.;i<4.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  // 用噪音扭曲坐标
  uv+=noise(uv+T*0.1)*0.1;

  // 使用噪音和缩放制作随机柔和锯齿形状
  float d = fbm(uv*vec2(5.,1.1)+vec2(0.,-T));
  d = uv.y+d*0.3;
  d = clamp(d, 0., 1.);
  // d = pow(.2/(1.-d),2.);

  vec3 red = vec3(1,0,0);
  vec3 yellow = vec3(1,1,0);

  vec3 c = mix(vec3(0), red, pow(smoothstep(0.,0.4,d),4.));
  c = mix(c, yellow, smoothstep(0.6,1.,d)*.5);


  // c = tanh(c/1.);

  O.rgb = d*c;

}