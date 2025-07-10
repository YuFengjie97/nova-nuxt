
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

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.xz *= rotate(T*.4);
    
    float d1 = dot(sin(p+T), cos(p.zxy+T))*.5+.5;
    d1 = max(0.01,d1);

    d = min(d, d1);
    d = max(d, length(p)-6.);
    d = max(0.01,d);

    O.rgb += (1.1+sin(vec3(3,2,1)+dot(p,p)*.1))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);
}