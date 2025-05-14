// https://www.shadertoy.com/view/Wf3GzS

float map(vec3 rd, float d, float z){
  // 迭代制造分型
  for(float f = 1.;f<1e2;f+=f) {
    vec3 p =  rd * z;
    p.z -= iTime;

    d = min(d, dot(p=sin(p*f+vec3(f,-f,0)), p.yzx)/f);
  }
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
    d = .004+.5*abs(d);
    z += d;
    O += exp(-z/vec4(2,9,4,1))/d;

    d = map(rd,d,z);
  }
  O = tanh(O/1e3);
}