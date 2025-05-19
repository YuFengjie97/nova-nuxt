#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define PI 3.141596
#define BaseRadius 0.5
#define NoiseRadius .8
#define scale vec2(0.02)
#define offset vec2(0., -iTime * 5e-3)


float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    n += a * texture(iChannel0, p * f).r;
    f *= 2.;
    a *= .5;
  }
  return n;

  // float H = 1.;
  // float G = exp2(-H);
  // float G = .5;
  // float f = 1.0;
  // float a = 1.0;
  // float t = 0.0;
  // for( int i=0; i<8; i++ )
  // {
  //     t += a*texture(iChannel0,f*p).r;
  //     f *= 2.0;
  //     a *= G;
  // }
  // return t;
}


vec2 twistUV(vec2 p){
  p *= scale;
  p += offset;
  return p;
}

float domainWraping(vec2 p){
  // return fbm(twistUV(p));
  return fbm(twistUV(p + fbm(twistUV(p))));
}


float getBlenderNoise(vec2 uv){
  vec2 q = vec2(atan(uv.y, uv.x), (length(uv)));
  vec2 q2= vec2(atan(uv.y,-uv.x), (length(uv)));

  float nR = domainWraping(q);
  nR *= smoothstep(-BaseRadius,0.,uv.x);

  float nL = domainWraping(q2+vec2(.1,.2));
  nL *= smoothstep(BaseRadius,0.,uv.x);

  float n = max(nR, nL);

  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  O.rgb *= 0.;
  O.a = 1.;


  float d = length(uv);
  float s = smoothstep(NoiseRadius,0.,abs(d-BaseRadius));

  float n = getBlenderNoise(uv);

  s *= n;
  
  float v = 0.5;
  float feath = .1;
  s = smoothstep(v, v+feath, s); // 噪音的伪距离场


  vec3 c_o = vec3(1.,0.,0.);
  vec3 c_i = vec3(0.,1.,0.);
  float glow = pow(1./s, 2.);  // 伪距离场发光
  vec3 c = sin(vec3(3.,2.,1.) + n) * glow;

  O.rgb = mix(O.rgb, c, s);
}