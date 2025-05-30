#define T iTime
#define PI 3.141596
#define red vec3(1,0,0)
#define yellow vec3(1,1,0)
#define white vec3(1)
#define black vec3(0,0,0)
#define R iResolution.xy
#define pix 1./R.y

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

vec4 Eye(vec2 p){
  p.x = abs(p.x);
  p-=vec2(0.2,0.06);
  float d = length(p);
  d += noise(p*20.+T*2.)*0.005;
  float aa = fwidth(d);

  float s1 = smoothstep(aa,0.,d-0.07);
  vec4 res = vec4(black, s1);
  
  float s2 = smoothstep(aa,0.,d-0.065);
  res.rgb = mix(res.rgb, white, s2);

  float s3 = smoothstep(aa,0.,d-0.01);
  res.rgb = mix(res.rgb, black, s3);

  return res;
}

vec4 Mouth(vec2 p){
  p -= vec2(0,-0.2);
  p *= vec2(1.,3.);
  float d = length(p);

  float aa = fwidth(d);
  float s1 = smoothstep(aa, 0., d-0.05);
  vec4 res = vec4(black, s1);

  float s2 = smoothstep(aa, 0., d-0.04);
  res.rgb = mix(res.rgb, vec3(0.93,0.38,0.23), s2);

  return res;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  float r = 0.4;


  // 以r为基准,然后跟一些r的比例增量
  float ver = smoothstep(-r*2.,   r*2.,  uv.y);       // 纵向,噪音自底部向上,变化量增加
  float hor = smoothstep( r*2.,   0.,    abs(uv.x));  // 横向,噪音增量随趋向中心增加

  vec2 uv_n = uv*vec2(ver, hor)*vec2(2,1.);

  float n = fbm(uv_n+vec2(0,-1)*T);
  float r_acc = abs(n);                               // abs用来剔除掉fbm的负值,*num控制具体增量范围
  r_acc *= ver*1.8;
  r_acc *= hor;


  vec2 uv_d = uv + noise(uv+T*vec2(0,1))*0.1 *vec2(0,1);  // 噪音跳动
  float d = length(uv_d)-r_acc; //

  float aa = 5./R.y;
  // aa = 0.1;
  float v1 = 0.5;
  float d1 = smoothstep(v1+aa,v1,d);
  vec3 c = mix(O.rgb, red, d1);

  float v2 = 0.3;
  float d2 = smoothstep(v2+aa,v2,d);
  c = mix(c, yellow, d2);

  O.rgb = c;

  vec4 eye = Eye(uv_d);
  O.rgb = mix(O.rgb, eye.rgb, eye.a);

  vec4 mouth = Mouth(uv_d);
  O.rgb = mix(O.rgb, mouth.rgb, mouth.a);
}