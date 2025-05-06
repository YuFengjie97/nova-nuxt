void mainImage(out vec4 O, in vec2 C){
  vec2 I = iResolution.xy;
  vec2 uv = (C*2.-I)/I.y;
  vec3 col = vec3(0.);

  float angle = (atan(uv.y, uv.x));
  float len = length(uv);


  float d = abs(len - 0.5);
  vec3 c = sin(vec3(9.,3.,1.) * iTime * .8 + angle)*0.3 + 0.2;
  float glow = pow(.1/d, 2.);
  col = glow * c;
  col = 1.-exp(-col);
  // col = tanh(col*0.8);

  O = vec4(col,1.);
}