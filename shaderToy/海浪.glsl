#define T iTime
#define white vec3(1)
#define SIN(v) sin(v)*0.5+0.5

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
  O.rgb = mix(vec3(0.11,0.86,0.98), vec3(0.04,0.35,0.96), 1.-uv.y);
  O.a = 1.;

  // 顶层涟漪
  float n1 = abs(fbm(uv*2.+vec2(0,T*0.5))-noise(uv+vec2(0,T*1.2))*.8);
  float v = 0.05;
  float feath = 0.05;
  float s = smoothstep(v+feath,v,n1);
  O.rgb = mix(O.rgb, white, s*0.5);

  // 底层涟漪
  float n2 = abs(fbm(uv*1.5+vec2(0,T*0.2)+vec2(.1))-noise(uv+vec2(0,T*.8))*0.5);
  v = 0.04;
  feath = 0.05;
  s = smoothstep(v+feath,v,n2);
  O.rgb = mix(O.rgb, white, s*0.3);

  // 大的高亮?
  float d = uv.y-sin(uv.x*10.)/15.-n1*.5;
  s = smoothstep(0.1,0.09,d);
  O.rgb = mix(O.rgb, white, s*0.6);
}