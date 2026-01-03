uniform float uTime;

varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vModelNormal;


float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}



void main(){
  vec4 pos = vec4(position, 1.);    // 模型坐标
  vec4 modelPos = modelMatrix * pos; // 世界空间下的坐标

  // glitch

  float glitchTime = modelPos.y - uTime;
  float glitchStrength = sin(glitchTime) + sin(glitchTime * 3.) * .5 + sin(glitchTime*6.) * .3;
  glitchStrength = smoothstep(.9, 1., glitchStrength) * .2;


  modelPos.x += glitchStrength * (hash12(modelPos.xz*.1)-.5);
  modelPos.z += glitchStrength * (hash12(modelPos.xz*.1)-.5);

  vec4 viewPos = viewMatrix * modelPos; // 相机坐标
  vec4 projectionPos = projectionMatrix * viewPos; // 投影矩阵坐标



  vec4 modelNormal = modelMatrix*vec4(normal, 1.);
  vModelNormal = normalize(modelNormal.xyz);



  vUv = uv;
  // vPosition = pos.xyz;
  vPosition = modelPos.xyz;
  vNormal = normal;



  gl_Position = projectionPos;
}