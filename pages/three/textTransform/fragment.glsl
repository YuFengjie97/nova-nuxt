uniform float uTime;

// varying vec2 vUv;
varying vec3 vModelPos;


void main(){
  vec3 col = vec3(0,0,0);

  vec3 C = vec3(3,2,1);
  C += dot(sin(vModelPos), vec3(2.1));

  col += sin(C+uTime*3.) * .5 + .5;

  gl_FragColor = vec4(col, 1.);
}
