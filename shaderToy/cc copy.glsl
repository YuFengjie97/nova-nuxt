#iChannel0 "./pic/noise_256.png"


#define TAU 6.283185
#define PI 3.1415926
#define T iTime

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
  // len = smoothstep(80.*pix, 0., abs(len-.5)-.4);

  float n1 = noise1D(lenId*.04+T*.1);
  uv *= rot2(n1*PI*5.);

  float ang = atan(uv.y, uv.x)/PI/2. + .5;
  ang *= floor(4.*(lenId+1.));
  float angId = floor(ang);
  ang = fract(ang);

  float d = smoothstep(.5,.45,abs(ang-.5)) * 
            smoothstep(.5,.45,abs(len-.5));

  vec3 col = sin(vec3(3,2,1)+3.*dot(vec2(lenId, angId), vec2(.1)))*.5+.5;

  O.rgb += d*col;
}