#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define T iTime
#define PI 3.141596
#define petalLen 0.9
#define petalNum 5.
#define rotateSpeed .5
#define rotateAmp 0.2
#define baseScale 4.
#define baseRadius 0.3

float noise(vec2 p){
  return texture(iChannel0, p).r;
}


float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    n += a * noise(p*f);
    f *= 2.;
    a *= .5;
  }
  return n;
}

vec2 twist(vec2 p, vec2 scale, vec2 offset){
  p *= scale;
  p += offset;
  return p;
}

float domainWraping(vec2 p, vec2 scale, vec2 offset){
  // return texture(iChannel0, twist(p,scale,offset)).r;
  // return fbm(twist(p, scale, offset));
  float f = fbm(twist(p, scale, offset));
  return fbm(twist(p + f, scale, offset));
}

float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}

float thunder(vec2 p, float n){
  return abs(p.y + n);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  float n = domainWraping(uv, vec2(0.01), vec2(0.,0.01) * T) * 0.5 - 0.25;
  float d = thunder(uv, n * 2.);
  // d *= n;
  d = glow(d, 0.01, 2.);


  O.rgb += d * vec3(1.,0.,0.);
}