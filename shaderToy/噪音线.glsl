#define T iTime
#define S smoothstep
#define TOTAL 4

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

#define dot2(v) dot(v,v)
// https://iquilezles.org/articles/distfunctions2d/
float sdBezier( in vec2 pos, in vec2 A, in vec2 B, in vec2 C )
{    
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    float kk = 1.0/dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);      
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx-3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    if( h >= 0.0) 
    { 
        h = sqrt(h);
        vec2 x = (vec2(h,-h)-q)/2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = clamp( uv.x+uv.y-kx, 0.0, 1.0 );
        res = dot2(d + (c + b*t)*t);
    }
    else
    {
        float z = sqrt(-p);
        float v = acos( q/(p*z*2.0) ) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3  t = clamp(vec3(m+m,-n-m,n-m)*z-kx,0.0,1.0);
        res = min( dot2(d+(c+b*t.x)*t.x),
                   dot2(d+(c+b*t.y)*t.y) );
        // the third root cannot be the closest
        // res = min(res,dot2(d+(c+b*t.z)*t.z));
    }
    return sqrt( res );
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
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;

  O.rgb *= 0.;
  O.a = 1.;

  float speed = 0.4;
  vec2 points[TOTAL];
  
  // 收集随机位置
  for(int i=0;i<TOTAL;i++){
    float ii = float(i);
    float x = noise(vec2(ii/10.+T*speed)) * R.x/R.y;
    float y = noise(vec2(ii/40.+T*speed));
    vec2 pos = vec2(x,y);
    points[i] = pos;
  }

  float d = 1e5;
  vec2 p1;
  vec2 c = (points[0] + points[1])/2.;

  // 调试查看点坐标
  // for(int i=0;i<TOTAL;i++){
    // d = min(d, length(uv-points[i]));
  // }

  
  // 绘制线条  https://www.shadertoy.com/view/WdK3Dz  getSegment
  for(int i=0;i<TOTAL-1;i++){
    p1 = c;
    c = (points[i] + points[i+1]) / 2.; 

    vec2 p2 = points[i];
    float d1 = sdBezier(uv, p1, p2, c);

    // d = min(d, d1-S(0.,1.,ii)*10.);
    d = min(d, d1-0.05);
  }
  // d = S(0.01,0.,d);
  d = pow(.05/d,2.);
  O.rgb += d;
}