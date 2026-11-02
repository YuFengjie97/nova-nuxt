// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture1.jpg"
#iChannel0 "./pic/noise_256.png"

#define TAU 6.283185
#define PI 3.1415926
#define T iTime
#define SPEED .1



float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){

  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

float noise2(vec2 p){
  return texture(iChannel0, p).r;
}


float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  float f = 1.;
  p.y -= T * SPEED;
  for(float i =0.;i<6.;i++){
    n += noise(p*f)*amp;
    amp *= .5;
    f *= 2.;
  }
  return n;
}


float domainWarping(vec2 p){
  // vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
  //                 fbm( p + vec2(1.2,5.3) ) );
  // return fbm( p + 10.0*q );
  vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                 fbm( p + vec2(.2,.3) ) );

  vec2 r = vec2( fbm( p + .1*q + vec2(.7,.2) ),
                 fbm( p + .1*q + vec2(.3,.8) ) );

  return fbm( p + 10.*r );
}

vec3 palette(float v){
  return sin(vec3(3,2,1)+v)*.5+.5;
}
vec3 dunhuangGradient(float v) {
    v = clamp(v, 0.0, 1.0);

    vec3 colors[10];
    colors[0] = vec3(0.22, 0.53, 0.40); // 石绿
    colors[1] = vec3(0.15, 0.35, 0.55); // 石青
    colors[2] = vec3(0.78, 0.52, 0.20); // 赭石
    colors[3] = vec3(0.75, 0.25, 0.15); // 朱砂
    colors[4] = vec3(0.88, 0.35, 0.20); // 朱红
    colors[5] = vec3(0.55, 0.20, 0.12); // 铁红
    colors[6] = vec3(0.92, 0.88, 0.80); // 蛤粉
    colors[7] = vec3(0.12, 0.10, 0.10); // 墨黑
    colors[8] = vec3(0.85, 0.70, 0.30); // 泥金
    colors[9] = vec3(0.90, 0.72, 0.58); // 肤色

    float scaled = v * 9.0;
    int i = int(floor(scaled));
    float t = fract(scaled);

    int next = min(i + 1, 9);
    return mix(colors[i], colors[next], t);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  float d1,d2;
  float dist  = length(uv);
  vec2 scale = vec2(1./smoothstep(2.,0.,dist), .4);


  {
    float a = atan(uv.y, uv.x)/PI;
    float mask = smoothstep(1.,.5,abs(a));
    vec2 q = vec2(a, dist);
    d1 = domainWarping(q*scale)*mask;
  }
  {
    float a = atan(uv.y, -uv.x)/PI;
    float mask = smoothstep(1.,.5,abs(a));
    vec2 q = vec2(a, dist);
    d2 = domainWarping(q*scale+.1)*mask;
  }
  float n =  max(d1, d2);

  vec3 col3 = vec3(0.17, 0.59, 0.47); // 石绿
  vec3 col2 = vec3(0.09, 0.33, 0.51); // 石青
  vec3 col1 = vec3(0.78, 0.28, 0.21); // 朱砂


  float dd1 = abs(length(uv)-.8)-n*.2;
  float dd2 = abs(length(uv)-.5)-n*.2;
  float dd3 = (length(uv)-.1)-n*.3;


  O.rgb += col1 * .1/max(0.01, dd1);
  O.rgb += col2 * .1/max(0.01, dd2)*2.;
  O.rgb += col3 * .2/max(0.01, dd3);
  O.rgb = 1.-exp(-O.rgb*.4);
}