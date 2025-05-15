#define PI 3.141596

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;


  uv *= 2.;


  vec2 m = (iMouse.xy*2.-R)/R.y;

  vec3 ro = vec3(0.,0.,-4.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float d = 0.;



  for(float i=0.;i<1e2;i++){
    vec3 p = z * rd + ro;

    if(iMouse.z > 0.) {
      p.xz *= rotate(m.x * PI * 2.);
      p.xy *= rotate(m.y * PI * 2.);
    }
    vec3 q = vec3(p.x, sin(p.x + iTime), cos(p.x+iTime));
    d = length(p-q)-0.5;


    z+=min(0.5,d);

    O.rgb += sin(vec3(3.,2.,1.)+d*1.5);

    if(z > 1e3 || d < 1e-3) break;
  }
  O.rgb = tanh(O.rgb * 0.1);
}