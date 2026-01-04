uniform float uTime;


varying vec3 vPosition;

void main(){
  vec3 col = vec3(0,0,0);

  col = sin(vec3(3,2,1)+ uTime + dot(cos(vPosition*.2), vec3(10)))*.5+.5;


  float d = length(gl_PointCoord-.5);
  d = pow(.1/d,2.);
  col *= d;

  gl_FragColor = vec4(col, d);
}