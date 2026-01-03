uniform float uDPR;
uniform sampler2D uNoise;
uniform float uTime;

varying vec3 vPosition;
varying vec3 vModelPos;

float noise(vec2 p){
  return texture2D(uNoise, fract(p)).r;
}



void main(){
  vec4 pos = vec4(position, 1.);

  vPosition = pos.xyz;

  vec4 modelPos = modelMatrix * pos;

  // float t = uTime * .01;

  // vec3 p = vec3(
  //   noise(fract(modelPos.xz*2. + t)),
  //   noise(fract(modelPos.xy*2. + t)),
  //   noise(fract(modelPos.yz*2. + t))
  // );

  // modelPos.xyz = (p-.5) * 10.;

  modelPos.xyz += cos(modelPos.zxy*1.*.8+uTime + cos(uTime+modelPos.zxy)*2.)*1.;
  modelPos.xyz += cos(modelPos.zxy*2.*.8+uTime + cos(uTime+modelPos.zxy)*2.)*.5;
  modelPos.xyz += cos(modelPos.zxy*4.*.8+uTime + cos(uTime+modelPos.zxy)*2.)*.25;

  vModelPos = modelPos.xyz;

  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  gl_Position = projectionPos;

  gl_PointSize = 40. * uDPR;
  gl_PointSize *= 1./-viewPos.z;
}