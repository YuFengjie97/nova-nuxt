#iChannel0 "./pic/noise_256.png"

#define PI 3.1415926
#define T iTime
#define pix 1./iResolution.y

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

mat2 rotate(float v){
  float c = cos(v);
  float s = sin(v);
  return mat2(c,-s,s,c);
}


float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
vec2 randomGradient(vec2 p){
  float a = hash(p)*PI*2.;
  // a+=T;
  return vec2(cos(a), sin(a));
}

float noise2(vec2 p){
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

  float d = 0.;
  mat2 r1 = rotate( T*.3);
  mat2 r2 = rotate(-T*.3);
  for(float i=0.;i<10.;i++){
    float n1 = noise2(r1*p*2.4+i*1.4);
    float n2 = noise2(r2*p*2.4+i*3.1);
    vec2 n = vec2(n1, n2);

    float circle = abs(length(p-n*.2)-.5);
    d += 1.*pix/circle;
    // d += smoothstep(.02,0.,circle);
  }
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I * 2. - R) / R.y;

  O.rgb *= 0.;

  float strength = 6.*pix;
  float r = pattern(uv);
  float g = pattern(uv*(1.-strength));
  float b = pattern(uv*(1.+strength));
  vec3 col = vec3(g,r,b);


  // float lum = dot(col, vec3(0.299, 0.587, 0.114));
  // col = mix(col, vec3(lum), .15);

  O.rgb += 1.-exp(-col*1.5);
}