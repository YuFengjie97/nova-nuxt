#define PI 3.141596

float hash11(float v){
  return fract(sin(v * 1364.259) * 4384.3166);
}

float noise11(float v){
  float i = floor(v);
  float f = fract(v);
  float v1 = hash11(i);
  float v2 = hash11(i+1.);
  // float u = smoothstep(0.,1.,f);
  return smoothstep(v1, v2, f);
}

vec2 hash22(vec2 v){
  return vec2(0.);
}
float fbm(float v){
  float freq = 2.;
  float amp = .5;
  float n = 0.;
  for(float i=0.;i<8.;i++) {
    n += amp * noise11(v * freq);
    freq *= freq;
    amp *= amp;
  }
  return n;
}

mat2 rot2D(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;
  float T = iTime;
  uv *= 10.;
  vec2 uvf = fract(uv);
  uvf -= 0.5;

  float n = fbm(length(uv)+iTime);
  uv += vec2(n * 0.1);
  // uv *= rot2D(n * 0.1);
  float range = 2.;
  for(float i=-range;i<=range;i++){
    float d = abs(range*sin(uv.x) - uvf.y+i);
    float s = smoothstep(0.1,0.,d);
    O.rgb += s;
  }
  

}