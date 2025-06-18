#define T iTime
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


  vec3 ro = vec3(0,0,-10);
  vec3 rd = normalize(vec3(uv, -1));
  vec3 p;
  float z;
  float d;
  for(float i=0.;i<100.;i++){
    ro.z += T*0.2;
    p = ro + rd * z;
    // p.z -= T*2.;

    vec3 P = p;
    mat2 R = rotate(p.z*0.1);
    p.xy *= R;
    
    
    p = mod(p,5.)/5.-.5;
    d = length(p.xy)-0.1;

    d = abs(d)+0.01;
    z += d;

    O += (sin(vec4(2,1,0,0)+2.*length(P.xy))+1.)/d;

    if(z>100. || d<1e-2) break;
  }
  O.rgb = tanh(O.rgb*1e-3);
}