#define T iTime
#define S smoothstep

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

// https://iquilezles.org/articles/smin/
float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    return max(k,min(a,b)) -
           length(max(k-vec2(a,b),0.0));
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;

  O.rgb *= 0.;
  O.a = 1.;

  float d = 1e10;
  float speed = 0.4;
  for(float i=0.;i<20.;i++){
    float x = noise(vec2(i*0.1+T*speed));
    float y = noise(vec2(i*0.1+T*speed+fract(speed)));
    vec2 pos = vec2(x,y);

    float d1 = length(uv-pos);
    d = smin(d, d1, .1);
    O.rgb = sin(vec3(3,2,1)+d1*1.);
  }
  d = pow(.1/d,2.);
  // d = S(0.01,0.,d);
  O.rgb *= d;

}