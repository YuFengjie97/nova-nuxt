uniform sampler2D uPosTex;
uniform float uDPR;

attribute vec2 aParticleUv;

varying vec3 vPosition;

void main(){
  vec4 particle = texture2D(uPosTex, aParticleUv);

  vec3 particlePos = particle.xyz;
  float particleLife = particle.w;

  vPosition = particlePos;

  vec4 pos = vec4(particlePos, 1.);


  vec4 modelPos = modelMatrix*pos;
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  gl_Position = projectionPos;

  gl_PointSize = uDPR * 30.;
  gl_PointSize *= 2. / -viewPos.z;
  gl_PointSize *= 1.-particleLife;
}