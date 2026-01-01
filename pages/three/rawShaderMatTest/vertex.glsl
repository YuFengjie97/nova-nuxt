uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

uniform float uFrequency;
uniform float uTime;
uniform bool uDisableRandom;

attribute vec3 position;
attribute float aRandom;
attribute vec2 uv;

varying float v_aRandom;
varying vec2 vUv;

void main(){
  vec4 pos = vec4(position, 1.);
  vec4 modelPos = modelMatrix * pos;

  modelPos.y += sin(modelPos.x*uFrequency + uTime) * .2 + aRandom*.1 * (uDisableRandom ? 0. : 1.);
  modelPos.y += cos(modelPos.z*uFrequency + uTime) * .2 + aRandom*.1 * (uDisableRandom ? 0. : 1.);
  v_aRandom = aRandom;

  vUv = uv;

  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  gl_Position = projectionPos;

  // gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.);
}