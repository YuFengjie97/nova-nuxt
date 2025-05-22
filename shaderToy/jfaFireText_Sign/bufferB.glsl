// 这个buffer是显示字符的

#iChannel1 "file://D:/workspace/nova-nuxt/public/img/texture_char.png"

float char(vec2 uv, vec2 i){
  float s = 4.;        // uv sclae
  vec2 p = uv * s;
  p = fract(p);

  // 使用rgb这三个通道会截取到step产生的边框
  //float d = texture(iChannel1, i/16.+p/16.).r;
  //d*=step(0.,uv.x) * step(uv.x,1./s) * step(0.,uv.y) * step(uv.y,1./s);


  float d = texture(iChannel1, i/16.+p/16.).a;
  d = smoothstep(0.5,0.4, d);
  d*=step(0.,uv.x) * step(uv.x,1./s) * step(0.,uv.y) * step(uv.y,1./s);

  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 uvChar = uv * .4;
  vec2 baseOffset = vec2(-.35, -.1);
  vec2 charOffset = vec2(0.15, 0.);
  float d1 = char(uvChar -baseOffset - charOffset * 0., vec2(6., 11.));
  float d2 = char(uvChar -baseOffset - charOffset * 1., vec2(9., 9.));
  float d3 = char(uvChar -baseOffset - charOffset * 2., vec2(2., 8.));
  float d4 = char(uvChar -baseOffset - charOffset * 3., vec2(5., 9.));

  float d = d1 + d2 + d3 + d4;
  O.rgb += d;
}