varying vec4 vCol;


void main(){

  vec2 uv = gl_PointCoord;
  float d = length(uv-.5);
  d = smoothstep(.5, .0, d);

  // vec3 col = vec3(1,0,0) * d;

  // gl_FragColor = vec4(vCol.rgb, d * vCol.a);
  gl_FragColor = vec4(vCol.rgb, d);
}