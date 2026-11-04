#iChannel0 "./pic/noise_256.png"


#define TAU 6.283185
#define PI 3.1415926
#define T iTime


float noise2(vec2 p){
  return texture(iChannel0, p).r;
}


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

float pattern(vec2 p){

  float len = length(p);
  float s = smoothstep(2., -2., sin(len*10.));

  float n = noise(p*2.*s);

  return n;
}


mat2 rot2(float v){
  float c = cos(v);
  float s = sin(v);
  return mat2(c,-s,s,c);
}
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise1D(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f); // smoothstep 插值
    return mix(hash11(i), hash11(i + 1.0), u);
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float pix = 1./R.y;

  O.rgb *= 0.;

  float len = length(uv)*10.;
  float lenId = floor(len);
  len = fract(len);
  len = smoothstep(80.*pix, 0., abs(len-.5)-.4);

  // float n1 = noise(vec2(lenId*.2, T*.3));
  float n1 = noise1D(lenId*.04+T*.12);
  uv *= rot2(n1*PI*5.);

  float ang = atan(uv.y, uv.x)/PI/2. + .5;
  ang *= 5.;
  float angId = floor(ang);
  ang = fract(ang);
  float mask = smoothstep(0., .01, ang+n1*.2) * 
               smoothstep(.9, .89, ang+n1*.2);

  vec3 col = sin(vec3(3,2,1)+lenId*.6+angId*2.24)*.5 + .5;

  O.rgb += len * mask * col;  
}