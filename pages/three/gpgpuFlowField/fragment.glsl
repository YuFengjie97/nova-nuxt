uniform float uTime;

varying vec3 vPosition;


void main(){
  vec2 uv = gl_PointCoord-.5;

  float t = uTime;

  float d = length(uv);
  // d = pow(.2/d, 2.);
  d = smoothstep(.3,.1,d);

  vec3 c = sin(vec3(3,2,1)+dot(cos(vPosition*1.),vec3(4.)))*.5+.5;

  vec3 col = c * d;

  gl_FragColor = vec4(col,d);
}