#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText/bufferA.glsl"

#define T iTime

float dot2(vec2 p) {
  return dot(p, p);
}

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


float getBlenderNoise(vec2 uv, vec2 scale, vec2 offset){
  float n = domainWraping(uv, scale, offset * T*1e-3);

  return n;
}

float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  float d = texture(iChannel1, uv).a/R.y;

  float cir = log(length(abs(uv-0.5)));
  vec2 dir = vec2(dFdx(cir), dFdx(cir));

  vec2 offset = dir+iTime * 0.001;

  vec2 scale = vec2(.05,.05);
  float n = getBlenderNoise(uv, scale, offset);

  d*=n;
  vec3 c1 = vec3(1.,0.,0.);
  d = glow(d,0.005,2.);

  O.rgb += d * c1;
}