#define S smoothstep
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

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  float total = 3.;
  float a = T*0.1;
  vec2 v = normalize(vec2(cos(a),sin(a)));
  vec2 v1 = v.yx*vec2(-1,1)*T*0.001;
  vec2 v2 = v.yx*vec2(1,-1)*T*0.001;

  vec2 p = uv*rotate(a);
  float n1 = fbm(uv+v1);
  float n2 = fbm(uv+v2);
  float n = (n1 + n2)/2.;

  float d = abs(p.y+n*S(1.2,0.,abs(p.x)));
  d = pow(.01/d,2.);
  O.rgb += d;
}