#define TAU 6.283185

uniform float uTime;

varying vec2 vUv;
varying float vHeight;



float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
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

float fbm(vec2 p){
  float n=0.;
  float amp = 1.;
  float fre = 1.;
  for(float i=0.;i<4.;i++){
    n += noise(p*fre)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float fbm2(vec2 p){
  float n = 0.;
  float fre = 1.;
  float amp = 1.;
  for(float i=0.;i<4.;i++){
    n += amp * abs(dot(cos(p.xy*fre), vec2(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

void main(){
  vec4 modelPos = modelMatrix * vec4(position, 1.);

  // float height = noise(modelPos.xz*.7 + vec2(0, uTime))*.5;
  // height += noise(modelPos.xz*3.7 + vec2(0, uTime))*.1;

  float height = fbm(modelPos.xz + vec2(0, uTime))*.3;
  
  modelPos.y += height * 2.;

  vHeight = height;


  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  vUv = uv;

  gl_Position = projectionPos;
}