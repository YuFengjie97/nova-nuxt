#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define T iTime

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

float sdf_gouyu(vec2 uv, float r) {
  return max(uv.y > 0. ? length(uv) - r : min(length(uv+vec2(r*.5,0)) - r*.5, length(uv-vec2(r,0))), -length(uv-vec2(r*.5,0))+r*.5);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.5;
  O.a = 1.;

  float d = sdf_gouyu(uv, 0.2);
  d = clamp(d,0.,1.);
  d = smoothstep(0.,0.1,d);
  float n = domainWraping(uv, vec2(0.009),  vec2(0.,1.) * T * 1e-2);

  float s = d*n;
  s = glow(s,.1,2.);

  O.rgb = vec3(1.,0.,0.) * s;
}