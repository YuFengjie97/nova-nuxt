#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText_Sign/bufferA.glsl"

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
  vec2 uv = I;
  O.rgb *= 0.;
  O.a = 1.;

  // vec4 D = texture(iChannel1, uv);
  vec4 D = texelFetch(iChannel1, ivec2(uv), 0);

  float d = (length(uv-D.xy) - length(uv-D.zw)) / R.y;
  vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
  col *= 1.0 - exp(-6.0*abs(d));
	col *= 0.8 + 0.2*cos(150.0*d);
  col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.005,abs(d)) );
  
  // float s = smoothstep(0.,0.4,d)*0.1;

  O.rgb = col;
}
