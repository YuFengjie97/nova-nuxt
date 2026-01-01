precision mediump float;

uniform sampler2D uTexture;

varying float v_aRandom;
varying vec2 vUv;

void main(){
  vec3 col = texture2D(uTexture, vUv).rgb;
  gl_FragColor = vec4(col, 1.);
  // gl_FragColor = vec4(v_aRandom,0.,0.,1.);
}