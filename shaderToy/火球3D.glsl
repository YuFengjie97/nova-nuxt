#define T iTime
#define showNor 1

mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)),
           dot(p, vec2(269.5, 183.3)));
  return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
  const float K1 = 0.366025404;
  const float K2 = 0.211324865;

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
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    n += a * noise(p*f);
    f *= 2.;
    a *= .5;
  }
  return n;
}


float getBlenderNoise(vec3 p){
  vec3 q1 = p, q2 = p;
  float scale = .3;
  float offset = T*10.;

  q1.y += -offset;
  q2.z += offset;

  float n1 = noise(q1.xy*scale);
  float n2 = noise(q2.xz*scale);
  return (n1 + n2)/2.;
}

float map(vec3 p){
  float r = 2.;
  float h = 8.;

  vec3 dir = p - vec3(0);
  float n = getBlenderNoise(p)*(smoothstep(-4.,1.,p.y)*.4+0.1);
  p += n * dir;

  // 球
  float d1 = length(p)-r;
  
  // 被截取下部分,缩小上部分的圆柱
  float d2 = length(p.xz)-smoothstep(h,0.,p.y)*r;
  d2 = max(d2, -p.y);

  d1 = min(d1, d2);

  return d1;
}

#define ZERO min(iFrame,0)
vec3 calcNormal(vec3 pos){
  vec3 n = vec3(0.0);
  for( int i=ZERO; i<4; i++ )
  {
      vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
      n += e*map(pos+0.0005*e);
  }
  return normalize(n);
}


//https://iquilezles.org/articles/distfunctions/
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float hash11(float v){
  return fract(sin(v*1345.154+112.36));
}
vec2 hash22(vec2 v){
  return sin(v * vec2(1,2))*0.5+0.5;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 m = (iMouse.xy*2.-R)/R.y;

  float d = 0.;
  float d_acc = 0.;
  float z = 0.;
  vec3 ro = vec3(0,0,-10);
  vec3 rd = normalize(vec3(uv,1));
  vec3 p;
  for(float i=0.;i<=50.;i++){
    p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    d = map(p);
    d = 0.04 + abs(d)*.25;
    d_acc += .1/d;
    z += d;

    if(z>1e2)break;
  }

  d_acc = pow(d_acc, 2.);
  vec3 c = sin(vec3(3,2,1)+T+p.z*0.01)*0.5+0.5;
  O.rgb = tanh(c*d_acc/z/1e2);

}