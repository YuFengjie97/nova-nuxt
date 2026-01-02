uniform float uTime;
uniform float uDPR;
// varying vec2 vUv;

// attribute vec3 position;
attribute vec3 position1;
attribute vec3 position2;


varying vec3 vModelPos;

void main(){
  vec3 pos_mix = mix(position1, position2, tanh(sin(uTime)*5.)*.5+.5);
  // vec3 pos_mix = position2;

  vec4 pos = vec4(pos_mix, 1.);
  vec4 modelPos = modelMatrix*pos;
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  // vUv = uv;
  vModelPos = modelPos.xyz;

  gl_Position = projectionPos;

  gl_PointSize = uDPR * 14.;
  gl_PointSize *= 1. / -viewPos.z;
}