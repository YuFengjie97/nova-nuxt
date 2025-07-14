#define T iTime
#define PI 3.141596
#define S smoothstep


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

  vec3 ro = vec3(0.,0.,-15.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;
  float id=0.;


  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    // p.xz*=rotate(T);
    // p.yz*=rotate(T);

    d = length(p)-5.;
    d = max(0.01, d);
    O.rgb += (1.1+sin(vec3(3,2,1)+p.x*.5))/d;

    for(float x=1.;x<=4.;x++){
      float r = 10.;
      float theta = x*2.+T*x;
      float phi = x*.2+T*x;
      float x1 = r * sin(theta) * cos(phi);
      float y1 = r * sin(theta) * sin(phi);
      float z1 = r * cos(theta);
      float d1 = length(p-vec3(x1,y1,z1))-1.;
      d1 = max(0.01,d1);

      O.rgb += (1.1+sin(vec3(3,2,1)+id))/d1;

      d = min(d, d1);
    }
    
    d = max(0.01,d);
    z += d;

    if(z>25. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}