#iChannel0 "./pic/noise_256.png"

#define T iTime

float noise(vec2 p){
  return texture(iChannel0, p).r;
}
float fbm(vec2 p){
  float a = 1.;
  float f = 1.;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    n += noise(p*f)*a;
    f *= 2.;
    a *= .5;
  }
  return n;
}

float easeOutQuart(float t) {
    return 1.0 - pow(1.0 - t, 4.0);
}

float pattern(vec2 q){
  
  float ang = atan(q.y, q.x);
  float dist = length(q);
  vec2 p = vec2(ang, dist);

  float d = fbm(p*vec2(1.,.1)*.1 + vec2(0., -T*.02));
  
  // 茴香豆的几种写法
  // return smoothstep(.2, 0., d-.5);
  // return pow(.01/max(0.01,(d-.5)), 2.);
  return exp(-d*10.)*200.;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;

  float e = .08;
  float r = pattern(uv*(1.-e));
  float g = pattern(uv);
  float b = pattern(uv*(1.+e));

  float dist = length(uv);
  // float mask = dist - fract(T*.5);
  float mask = dist - easeOutQuart(fract(T))*.6-.1;
  mask = smoothstep(.5, .0, mask)*smoothstep(-.1,.1,mask);

  O.rgb = vec3(r,g,b)*mask;
}