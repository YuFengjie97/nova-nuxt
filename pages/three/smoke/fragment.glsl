uniform sampler2D texNoise;
uniform float uTime;

varying vec2 vUv;


void main() {
  vec4 col = vec4(0,0,0,0);


  vec2 uv_tex = vUv;
  vec2 uv_cen = vUv - .5;

  

  uv_tex *= vec2(1., .5);
  uv_tex.y -= uTime * .3;

  uv_tex = fract(uv_tex);

  float d = texture(texNoise, uv_tex).r;
  d = smoothstep(0.1, 1., d);
  // d = pow(d, 2.);


  vec4 c = sin(vec4(3,2,1,0.) + dot(sin(vUv), vec2(2.1)) - uTime ) * .5 + .5;
  col += c*2. * d;

  float mask = smoothstep(.4,0.,abs(uv_cen.x)); // 横向渐变
  mask *= smoothstep(-.5, -.4, uv_cen.y);
  mask *= smoothstep(.5, -.1, uv_cen.y);
  
  col *= mask;
  col.xyz *= 2.;
  // col = vec3(mask);

  gl_FragColor = vec4(col);
  // gl_FragColor = vec4(1,0,0,1);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}