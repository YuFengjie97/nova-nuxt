#define PI 3.141596


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec2 twist(vec2 p){
  float freq = 0.2;
  float amp = 2.;
  mat2 rot = rotate(.4);
  for(float i=0.;i<4.;i++){
    p *= rot[0];

    // rot *= rotate(1.3);
  }
  return p;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*0.5)/R.y;
  vec3 col = vec3(0.);

  uv *= 4.;
  // uv = twist(uv);
  vec2 uvf = fract(uv);
  uvf -= 0.5;
  float d = abs(uvf.y);
  col += d;



  O = vec4(col, 1.);
}