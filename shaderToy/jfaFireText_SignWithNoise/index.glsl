#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText_Sign/bufferB.glsl"



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
  float n = domainWraping(uv, scale, offset);

  return n;
}

float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I;
  O.rgb *= 0.;
  O.a = 1.;

  // vec4 D = texture(iChannel1, uv/R.y);
  vec4 D = texelFetch(iChannel1, ivec2(uv), 0);   // 必须使用texelFetch,用归一化的uv坐标来展示jfa计算后的图像,会导致撕裂,挤压,不连续

  vec2 scale = vec2(0.0002, 0.0001);
  vec2 offset = vec2(0., -1.) * T * 2e-2;
  float n = getBlenderNoise(uv, scale, offset);

  float d = (length(uv-D.xy) - length(uv-D.zw)) / R.y;
  d = d < 0. ? 1. : d;

  d *= n;

  vec3 c1 = vec3(1.,.6,0.);
  vec3 c2 = vec3(1.,.3,0.);

  float d1 = smoothstep(0.,0.1,d);
  d1 = glow(d1,0.05,2.);
  O.rgb = mix(O.rgb, c1, d1);

  float d2 = smoothstep(0.0,0.1,d);
  d2 = glow(d2,0.01,2.);
  O.rgb = mix(O.rgb, c2, d2 > .6 ? 1. : 0.);
}
