
uniform sampler2D texNoise;
uniform float uTime;

varying vec2 vUv;


#include ../../../shaderUtils/rotate.glsl


void main(){
  vec4 pos = vec4(position, 1.);


  float n = texture(
    texNoise,
    vec2(.5, fract(uv.y*.1 - uTime * .1))
    ).r;
  
  // 旋转
  pos.xz *= rotate2D(n * .2 +  uv.y * 2.2 - uTime * .2);

  // pos.xz *= rotate2D(pos.y);

  // 平移
  vec2 offset = vec2(
    texture(texNoise, vec2(.2, fract((uv.y*.1 - uTime*.1)))).r,
    texture(texNoise, vec2(.8, fract((uv.y*.1 - uTime*.1)))).r
  )-.5;

  pos.xz += offset * 3. * smoothstep(-0.1, 1., uv.y);
  
  vec4 modelPos = modelMatrix*pos;
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;


  vUv = uv;

  gl_Position = projectionPos;
}