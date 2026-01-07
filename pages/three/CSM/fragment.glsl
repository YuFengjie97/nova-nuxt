uniform vec3 uColorA;
uniform vec3 uColorB;

uniform float uTime;


varying float vWobble;

void main(){
  float t = uTime;
  // csm_FragColor = vec4(1,1,0,1);


  vec3 col = mix(uColorA, uColorB, vWobble);

  csm_DiffuseColor = vec4(col, 1);
  // csm_FragColor = vec4(col, 1.);
}