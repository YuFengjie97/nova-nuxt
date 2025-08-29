#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

// 可自定义外层,内层颜色,火焰!

#define PI 3.141596
#define BaseRadius 0.5
#define NoiseRadius .4
#define scale vec2(0.02)
#define offset vec2(0., -iTime * 5e-3)
// #define offset vec2(0., 5e-3)

// https://iquilezles.org/articles/distfunctions2d/
float sdOrientedVesica( vec2 p, vec2 a, vec2 b, float w )
{
    float r = 0.5*length(b-a);
    float d = 0.5*(r*r-w*w)/w;
    vec2 v = (b-a)/r;
    vec2 c = (b+a)*0.5;
    vec2 q = 0.5*abs(mat2(v.y,v.x,-v.x,v.y)*(p-c));
    vec3 h = (r*q.x<d*(q.y-r)) ? vec3(0.0,r,0.0) : vec3(-d,0.0,d+w);
    return length( q-h.xy) - h.z;
}

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

float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  O.rgb *= 0.;
  O.a = 1.;

  float size = 0.3;

  // 体素化
  // float s = .02;
  // uv = (floor(uv / s) + 0.5) * s;
  
  float d = length(uv);
  float d2 = sdOrientedVesica(uv, vec2(0.,size), vec2(0.,-size),0.06);
  d2 = clamp(d2, 0.,1.);

  d = max(d, -d2);

  float n = getBlenderNoise(uv);

  d *= n;
  d2 *= n;

  O.rgb = mix(O.rgb, vec3(0.99,0.75,0.3), glow(d,0.4,4.));
  O.rgb = mix(O.rgb, vec3(0.61,0.,0.),    glow(d,0.4,4.) > 1.5 ? 1. : 0.);
  O.rgb = mix(O.rgb, vec3(0.,0.,0.),      glow(d,0.4,2.) > 3.5 ? 1. : 0.);
  O.rgb = mix(O.rgb, vec3(0.06,0.37,0.03),glow(d2,0.07,2.));


}