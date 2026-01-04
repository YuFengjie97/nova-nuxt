#include ../../shaderUtils/glsl-noise/simplex/3d.glsl
#include ../../shaderUtils/rotate.glsl

uniform float uDPR;
uniform sampler2D uNoise;
uniform float uTime;

varying vec3 vPosition;

float noise(vec2 p){
  return texture2D(uNoise, fract(p)).r;
}



void main(){
  vec4 pos = vec4(position, 1.);

  // float n = snoise(cos(pos.xyz*.2) + uTime * .1);
  // float n = snoise(cos(pos.xyz*.2 + uTime * .1));
  float n = snoise(pos.xyz*.2 + uTime * .1);

  pos.xy *= rotate2D(n * 2. + uTime);
  pos.xz *= rotate2D(n * 2. + uTime);
  pos.yz *= rotate2D(n * 2. + uTime);

  // vec3 dir = normalize(cos(pos.zxy));
  vec3 dir = normalize(cos(vec3(3,2,1)+n));

  pos.xyz += n * 4. * dir;

  vPosition = pos.xyz;

  vec4 modelPos = modelMatrix * pos;
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  gl_Position = projectionPos;

  gl_PointSize = 50. * uDPR;
  gl_PointSize *= 1./-viewPos.z;
}