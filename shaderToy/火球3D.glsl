#define T iTime
#define showNor 0

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
  float n = 0.;
  n += 1. * noise(p*.2);
  n += 2. * noise(p*.25);
  n += 3. * noise(p*.15);
  n += 4. * noise(p*.05);
  return n;
}


float getBlenderNoise(vec3 p){
  vec3 q1 = p, q2 = p;
  float scale = .35;
  float offset = T*10.;

  q1.y += -offset;
  q2.z += offset;

  float n1 = noise(q1.xy*scale);
  float n2 = noise(q2.xz*scale);
  // float n1 = fbm(q1.xy * 2.);
  // float n2 = fbm(q2.xz * 2.);
  return (n1 + n2)/2.;
}

float map(vec3 p){
  float r = 2.;
  float h = 9.;
  p.xy += vec2(0,2); // 火球位置

  vec3 dir = p - vec3(0);
  float n = getBlenderNoise(p)*(smoothstep(-4.,1.,p.y)*.4+0.1);
  p += n * dir;

  // 球
  float d1 = length(p)-r;
  
  float d2 = length(p.xz);
  // 圆柱体,圆柱体的半径被smoothstep自0到上变细
  d2 -= smoothstep(h,0.,p.y)*r;
  // 圆柱体去掉下面多余部分
  d2 = max(d2, -(-p.y+h));
  // 圆柱体去掉上面多余部分
  d2 = max(d2, -(p.y));
  

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

    #if showNor
    if(i==50.){
      O.rgb = calcNormal(p);
    }
    #endif

    if(z>1e2)break;
  }

  #if showNor!=1
  d_acc = pow(d_acc, 2.);
  vec3 c = sin(vec3(10,6,2)+T+p.z*0.1)*0.5+0.5;
  O.rgb = tanh(c*d_acc/z/1e2);
  #endif
}