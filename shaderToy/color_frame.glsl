// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/noise_1.png"


#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 Tonemap_ACES(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (x * (a * x + b)) / (x * (c * x + d) + e);
}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  float ang = atan(uv.y,uv.x);

  vec3 col = vec3(0);

  O.rgb *= 0.;
  O.a = 1.;

  float glow_r = .02;
  float r = .5;

  // float d = abs(length(uv)-r);
  float d = abs(sdBox(uv, vec2(.4,.6))-.02);
  float d1 = 1.2*glow_r/d;
  col += d1;

  // vec3 c = sin(vec3(3,2,1)+2.3);
  vec3 c = sin(vec3(3,2,1)+ang+T);
  float d2 = glow_r/d;
  col += c * d2;

  float nt = T*.1;

  float n  = noise(uv+vec2(0. , nt));
  float n1 = noise(uv+vec2(0. ,-nt));
  float n2 = noise(uv+vec2( nt,0.));
  float n3 = noise(uv+vec2(-nt,0.));
  n = min(min(min(n,n1),n2),n3);
  // float n = noise(uv*rotate(T));
  // float n1 = noise(uv*rotate(-T));
  // n = min(n, n1);
  n = .04/n;
  vec3 c2 = sin(vec3(3,2,1) + ang - T) * 1.;
  col += n*c2*smoothstep(.05,0.,d);

  O.rgb = col;

  O.rgb = tanh(O.rgb/2.);
  // O.rgb = Tonemap_ACES(O.rgb);
}