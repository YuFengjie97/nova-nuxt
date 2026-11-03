#iChannel0 "./pic/noise_256.png"

#define T iTime
#define s1(v) (sin(v)*.5+.5)
#define PI 3.1415926



float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float pattern(vec2 p){
  float d1 = (length(p)-.5);
  float d2 = (sdBox(p, vec2(.5)));

  float ang = atan(p.y, p.x)/PI/2.;
  float gm = smoothstep(0.15, .1, abs(fract(ang+T*.5)-.5));
  float d = mix(d2,d1,gm);
  return .02/max(0.01, abs(d));
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  float pix = 1./R.y;

  float g = pattern(uv);
  float r = pattern(uv*.985);
  float b = pattern(uv*1.015);

  O.rgb += vec3(r,g,b);
}