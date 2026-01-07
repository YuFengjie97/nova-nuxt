#include ../../../shaderUtils/glsl-noise/simplex/4d.glsl

uniform float uTime;
uniform float uDeltaTime;
uniform float uNoisePosFre;
uniform float uNoiseSpeed;
uniform float uNoiseStrength;

uniform float uWrapNoisePosFre;
uniform float uWrapNoiseSpeed;
uniform float uWrapNoiseStrength;


attribute vec4 tangent;

varying float vWobble;

uniform vec3 uColA;


float getWobble(vec3 p, float t){
  vec3 wrapPos = p + snoise(vec4(p * uWrapNoisePosFre, t * uWrapNoiseSpeed)) * uWrapNoiseStrength;

  return snoise(vec4(wrapPos*uNoisePosFre, t * uNoiseSpeed)) * uNoiseStrength;
}


void main(){
  float t = uTime;
  float dt = uDeltaTime;

  vec3 pos = csm_Position;
  // 根据位置与切线通过叉乘获取副切线方向
  vec3 biTangent = cross(pos, tangent.xyz);

  // 根据切线和副切线分别获取两个方向的邻居点的位置
  float e = .01;
  vec3 posA = pos + tangent.xyz * e;
  vec3 posB = pos + biTangent * e;

  // 邻居点依照噪音,进行位置变换
  posA += getWobble(posA, t) * normal;
  posB += getWobble(posB, t) * normal;

  float wobble = getWobble(pos, t);
  vWobble =  smoothstep(-1., 1., wobble / uNoiseStrength);
  pos += wobble * normal;

  // 分别获取当前点到邻居的方向
  vec3 toA = normalize(posA - pos);
  vec3 toB = normalize(posB - pos);

  // 根据方向,通过叉乘获取新的法线
  csm_Normal = cross(toA, toB);

  csm_Position.xyz = pos;
}