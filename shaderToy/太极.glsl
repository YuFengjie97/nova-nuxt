#define S smoothstep
#define PI 3.141596
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

//  MeDope's teach  https://www.shadertoy.com/view/3XsSWB
float sdf_gouyu(vec2 uv, float r) {
 float d = max(uv.y > 0. ?
     length(uv) - r 
     :
     min(length(uv+vec2(r*.5,0)) - r*.5,
         length(uv-vec2(r, 0  ))),
     -length(uv-vec2(r*.5,0))+r*.5);
  return d;
  // return d < 0. ? 0. : d;
}
mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
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

  // O.rgb = vec3(0.4,0.4,0.1);     // 黑色很特殊,既是 黑 又是 无,为了保证所有形状都展示出来,这里不能设置默认全黑
  O.rgb *= 0.;
  O.a = 1.;

  float r = 0.5;

  float n = fbm(uv*rotate(T) * 4.);                 // 旋转的噪音
  vec2 p = uv*rotate(-T*0.5);
  float d = sdf_gouyu(p+n*0.1, r);
  float d2 = length(p-vec2(-0.25,0))-0.05-0.05*n;   // 扣掉的空心
  d = max(d,-d2);
  float s = S(0.01,0.,d);                           // 使用smoothstep确认主形状
  O.rgb = mix(O.rgb, vec3(0), s);
  d = pow(.01/d,2.);                                // 使用glow来发光
  O.rgb = mix(O.rgb, vec3(1), d);


  p = uv*rotate(PI-T*0.5);                          //与另一半多旋转PI
  d = sdf_gouyu(p+n*0.1, r);
  d2 = length(p-vec2(-0.25,0))-0.05-0.05*n;
  d = max(d,-d2);
  s = S(0.01,0.,d);
  O.rgb = mix(O.rgb, vec3(1), s);
  d = pow(.01/d,2.);
  O.rgb = mix(O.rgb, vec3(0), d);
}