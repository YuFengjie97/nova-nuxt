#define T iTime
#define PI 3.141596
#define S smoothstep
#define dot2(v) dot(v,v)


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

mat2 rotate(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c,-s,s,c);
}

// sdf function is from https://iquilezles.org/articles/distfunctions2d/
float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float sdRhombus( in vec2 p, in vec2 b ) 
{
    p = abs(p);
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*vec2(1.0-h,1.0+h) );
    return d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}
float sdArc( in vec2 p, in vec2 sc, in float ra, float rb )
{
    // sc is the sin/cos of the arc's aperture
    p.x = abs(p.x);
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}

float sdStab(vec2 p){
  float d = 1e4;
  // 旋转的刺
  float a = PI*0.3;
  float offset = .5;
  for(float i=0.;i<3.;i+=1.){
    vec2 q = vec2(abs(p.x), p.y);
    q *= rotate(a*i);
    q.y -= offset;
    float d1 = sdRhombus(q, vec2(0.03,0.24));
    d = min(d, d1);
  }
  return d < 0. ? 0. : d;
}

float sdCir(vec2 p){
  // 弧
  vec2 q = p * rotate(PI / 2.);
  float a = atan(q.y,q.x)/PI;
  float cut = S(0.,.9,abs(a));
  float sca = 2.5;
  float r = 0.02 * smoothstep(0.2,0.6,abs(a));
  float d = sdArc(p, vec2(sin(sca), cos(sca)), 0.5, r);
  return d < 0. ? 0. : d;
}


float star(vec2 p, float r) {
    p = abs(p);
    float angle = radians(4.);
    // float angle = radians(45.0); // 或者你可以设为 atan(1.0)，固定45度
    vec2 dir1 = vec2(cos(angle), sin(angle));     // 第一条斜线方向
    vec2 dir2 = vec2(cos(PI/2.-angle), sin(PI/2.-angle));   // 第二条斜线方向

    // 投影
    float d1 = dot(p, dir1) - r;
    float d2 = dot(p, dir2) - r;
    return min(d1, d2);
}

float glow(float d, float r, float ins){
  return pow(r/d,ins);
}

void mainImage( out vec4 O, in vec2 I )
{
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 uv_rot = uv * rotate(-PI/2.); // 旋转PI/2绕开atan的断裂处

  vec2 p = vec2(atan(uv_rot.y,uv_rot.x)/PI, length(uv_rot));
  vec2 p2 = p;  

  p *= vec2(4.,1.);
  p.y -= T*0.7;
  float n = fbm(p);
  float d = sdStab(uv+n*0.03);

  float d1 = sdCir(uv);
  d1 -= n*0.02;

  d = min(d,d1);
  d = glow(d, 0.01,2.);
  O.rgb+=d;

  p2 *= 4.;
  p2.y -= T*0.3;
  n = abs(fbm(p2));
  float aa = fwidth(n);
  n = S(aa+0.05,0.05,n);
  d = length(uv);
  aa = fwidth(d);
  float range = S(0.45,0.3,d) * (d-0.15);
  d *= range * n*10.;
  O.rgb += d;

  // d = length(uv-vec2(0,0.5));
  d = star(uv-vec2(0,0.5), 0.01);
  d = glow(d,0.03*sin(T),2.);
  O.rgb += d;
}