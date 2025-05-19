#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define PI 3.141596
#define BaseRadius 0.4
#define NoiseRadius .3

float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<8.;i++){
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

vec3 grid(vec2 p){
  vec3 red = vec3(1.,0.,0.);
  vec3 green = vec3(0.,1.,0.);

  p = fract(p);
  float d = min(abs(p.x), abs(p.y));
  float aa = 0.01;
  float s1 = smoothstep(0.02+aa,0.02,d);
  vec3 col = s1 * red;

  p *= 5.;
  p = fract(p);
  float d2 = min(abs(p.x), abs(p.y));
  float aa2 = 0.01;
  float s2 = smoothstep(0.02+aa,0.02,d2);
  col = mix(col, green, s2);

  return col;
}


float getBlenderNoise(vec2 uv, vec2 scale, vec2 offset){
  vec2 q = vec2(atan(uv.y, uv.x), (length(uv)));
  vec2 q2= vec2(atan(uv.y,-uv.x), (length(uv)));

  q *= scale;
  q += offset;
  q2 *= scale;
  q2 += offset;

  float grad = smoothstep(NoiseRadius,0.,q.x);

  float n = 0.;
  float nR = fbm(q) * smoothstep(-BaseRadius,0.,uv.x);
  float nL = fbm(q2+vec2(.1,.2)) * smoothstep(BaseRadius,0.,uv.x);
  n = max(nR, nL);
  n *= 2. + n * 4.; // 补强特征

  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  float T = iTime * 6e-3;
  O.rgb *= 0.;
  O.a = 1.;

  // O.rgb += grid(uv);


  float d = length(uv);
  float s = smoothstep(NoiseRadius,0.,abs(d-BaseRadius));


  vec2 scale = vec2(0.02);
  vec2 offset = vec2(0., -T)*0.9;
  float n = getBlenderNoise(uv, scale, offset);


  s *= n;
  float v = 0.5;
  float feath = 0.1;

  vec3 c = sin(vec3(3.,2.,1.) + s);

  s = smoothstep(v, v+feath, s);
  O.rgb = mix(O.rgb, c, s);
}