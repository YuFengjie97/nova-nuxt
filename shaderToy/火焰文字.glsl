#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/public/img/texture_char.png"

#define T iTime

float dot2(vec2 p) {
  return dot(p, p);
}


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
}

float char(vec2 uv, vec2 i){
  float s = 4.;        // uv sclae
  vec2 p = uv * s;
  p = fract(p);

  float d = texture(iChannel1, i/16.+p/16.).r;
  d*=step(0.,uv.x) * step(uv.x,1./s) * step(0.,uv.y) * step(uv.y,1./s);

  return d;
}

vec2 twist(vec2 p, vec2 scale, vec2 offset){
  p *= scale;
  p += offset;
  return p;
}



float domainWraping(vec2 p, vec2 scale, vec2 offset){
  // return fbm(twistUV(p));
  float f = fbm(twist(p, scale, offset));
  return fbm(twist(p + f, scale, offset));
}


float getBlenderNoise(vec2 uv){
  uv.y = 1.-abs(uv.y);

  vec2 scale = uv.y * vec2(.03, 0.01);
  float n = domainWraping(uv, scale, vec2(0.01, .003 * T));

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

  vec2 uvChar = uv * .4;
  vec2 baseOffset = vec2(-.35, -.1);
  vec2 charOffset = vec2(0.15, 0.);
  float d1 = char(uvChar -baseOffset - charOffset * 0., vec2(6., 11.));
  float d2 = char(uvChar -baseOffset - charOffset * 1., vec2(9., 9.));
  float d3 = char(uvChar -baseOffset - charOffset * 2., vec2(2., 8.));
  float d4 = char(uvChar -baseOffset - charOffset * 3., vec2(5., 9.));

  float d = d1 + d2 + d3 + d4;

  float n = getBlenderNoise(uv);
  d += n*n*3.;
  d /= 2.2;
  d = glow(1.-d, .3, 2.);
  vec3 red = vec3(1.,0.,0.);


  O.rgb += d * red;
}