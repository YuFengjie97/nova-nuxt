uniform sampler2D uParticleTex;
uniform float uTime;
uniform float uDeltaTime;
uniform float uDPR;

attribute vec2 aParticleUV;
varying vec4 vCol;


void main(){
  vec4 particle = texture2D(uParticleTex, aParticleUV);

  // vec3 pos = position;

  vec3 pos = particle.xyz;
  float life = particle.w;

  vec4 modelPos = modelMatrix * vec4(pos, 1.);
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;


  gl_Position = projectionPos;
  gl_PointSize = 10. * uDPR;
  gl_PointSize *= 2./ -viewPos.z;
  // gl_PointSize *= life;


  // 计算颜色部分
  vec4 col = vec4(0);
  col.rgb = sin(vec3(3,2,1) + dot(cos(position*2.1), vec3(1.1)));
  vCol = col;
}