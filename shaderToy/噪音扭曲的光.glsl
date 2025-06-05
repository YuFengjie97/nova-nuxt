#define Pi 3.141596
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


float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv*=3.;

  float a = 2.;
  float f = 0.5;
  for(float i=1.;i<3.;i++){
    uv *= a*rotate(sin(uv.x)*f);
    a *= .5;
    f *= 1.1;
  }


  vec2 p = uv;
  vec2 grid = min(vec2(1), .5*fwidth(p)/abs(p-round(p)));
  O.rgb += max(grid.x, grid.y)*.6;

  vec3 c = sin(vec3(3,2,1)+10.*floor(abs(uv.x)))*0.5+0.5;

  float d;
  d = length(uv-sin(vec2(1, 4)*T)*3.);
  d = 1.-exp(-.1/d);
  O.rgb += c*d;
  d = length(uv+sin(vec2(1,-4)*T)*3.);
  d = 1.-exp(-.1/d);
  O.rgb += c*d;
}