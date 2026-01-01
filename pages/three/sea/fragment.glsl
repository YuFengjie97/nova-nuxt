uniform sampler2D texUv;
uniform float uTime;
uniform vec3 colTop;
uniform vec3 colBottom;


varying vec2 vUv;
varying float vHeight;



void main(){

  vec2 uv_cen = vUv - .5;

  // vec3 col = texture2D(texUv, vUv).rgb;

  // vec3 col_b = vec3(.1,0,0);
  // vec3 col_t = vec3(0,1,0);
  vec3 col_b = colBottom;
  vec3 col_t = colTop;

  vec3 col = mix(col_b, col_t, vHeight*4.);

  float d = length(uv_cen);
  d = abs(sin(d*10.-uTime));
  d = .1/d;
  col += d;

  // col = colBottom;

  gl_FragColor = vec4(col,1);
}