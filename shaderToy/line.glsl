#define PI 3.141596
#define freq 5.5

mat2 rot(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float s(float v){
  return sin(v)*0.5+0.5;
}

float hash11(float v){
  return fract(sin(v*3.568+7.395));
}

vec2 hash12(float v){
  float x = hash11(v);
  float y = hash11(v+1.5);
  return vec2(x,y);
}

/**
size xy分别对应线条宽度和长度
*/
vec4 line(vec2 p, vec2 size, float a, float colorOffset){
  p *= rot(a);
  float d = abs(p.y);
  d = pow(size.x/d, 1.7);
  
  float mask = smoothstep(size.y,0., abs(p.x));
  d*=mask;
  vec3 col = d * sin(vec3(3.,3.,1.) * colorOffset + p.x);
  return vec4(col, d);
}

vec4 randomLine(vec2 p) {
  float t = iTime*freq;
  float ti = floor(t);
  float tf = fract(t);
  float seed = ti;
  vec2 offset = hash12(seed) * 0.1-0.05;
  vec2 size = vec2(0.005,0.4) * (hash12(seed) + 1.);
  float colorOffset = tf;
  float angle = hash11(seed)* PI * 20.;
  
  vec4 l = line(p - offset, size, angle, colorOffset);
  return l;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*.5)/R.y;
  vec3 col = vec3(0.);

  vec4 l = randomLine(uv);
  
  vec3 lastFrame = texture(iChannel0, I/R.xy).rgb;
  
  //col = mix(col, lastFrame, 0.9);
  col += lastFrame*0.9;
  col += l.rgb;
  
  


  O = vec4(col, 1.);
}