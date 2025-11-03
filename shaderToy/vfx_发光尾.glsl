// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256_rgb.png"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
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
float noise21(vec2 p){
  return texture(iChannel0, p).r;
}

vec3 C = vec3(3,2,1);
float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise21(p)*amp;
    amp *= .5;
    p *= 2.;
    // C += n*.1;
    // C += dot(p,vec2(.1));
    C += n*.3 + dot(p,vec2(.05,.02));
  }
  return n;
}

float fbmWrap(vec2 p){
  vec2 q = vec2(
                fbm(p+vec2(13.24,42.74)),
                fbm(p+vec2(51.16,17.93))
                );
  return fbm(q);
}


float sdVesica(vec2 p, float r, float d)
{
    p = abs(p);

    float b = sqrt(r*r-d*d);  // can delay this sqrt by rewriting the comparison
    return ((p.y-b)*d > p.x*b) ? length(p-vec2(0.0,b))*sign(d)
                               : length(p-vec2(-d,0.0))-r;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R/2.)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  // 主形状
  // float d = sdVesica(uv, .5, .4);
  float d = length(uv);

  // 参考网格
  vec2 grid = fract(uv/.1);
  grid = S(-10./R.y,.0,abs(grid-.5)-.5);
  float d_grid = max(grid.x,grid.y);
  O.rgb += d_grid;


  vec2 uv2 = vec2(atan(uv.y, uv.x), length(uv));
  uv2.y += -T*.3;
  // uv2.x = sin(uv2.x*5.)/5.;

  // fbm限制d
  float n = fbmWrap(uv2*0.01);
  n = pow(n, 10.); // 噪音特征增强
  n *= S(.1,.3,d);


  // 发光
  float glow = pow(.2/n, 2.);

  vec3 col = s1(C);
  col = mix(vec3(0), col, glow);
  col *= S(.3,.1,d);

  O.rgb += col;
}