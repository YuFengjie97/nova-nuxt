// https://www.shadertoy.com/view/3cc3DN


float map(vec3 p){
  p.z += 8.;
  p.yz *= mat2(cos(iTime + vec4(0,11,33,0)));
  float  d = .2*max(.2+abs(dot(cos(p),cos(p.yzx/.6))), length(p)-4.);
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = R.xyy;
  vec3 rd = normalize(vec3(I+I, 0.) - ro);

  float z = 0.;
  float d = 0.;

  // rayMarch
  for(float i=0.;i<5e1;i++){
    vec3 p = rd * z;
    d = map(p);
    z += d;
    O += (cos(p.y + vec4(6,1,3,0))+1.5)/d;
  }

  O = tanh(O/1e3);
}