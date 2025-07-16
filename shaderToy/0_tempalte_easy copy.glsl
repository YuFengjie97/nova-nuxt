#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float map(vec3 p) {
  for(float i=1.;i<5.;i*=1.4){
    p += (dot(cos(p.yzx*i)/i,vec3(.4)));
  }
  float d = dot(p, vec3(0,1,0));
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,3.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float zMax = 100.;
  vec3 p;

  for(float i =0.;i<100.;i++){
    p = ro + rd * z;

    float d = map(p);
    d = max(d, .01);
    // d = abs(d)+.1;

    O.rgb += (1.1+sin(vec3(3,2,1)+(p.x+p.z)*.05))/d;

    if(d<1e-3) break;
    z += d;
    if(z>zMax) break;
  }
  O.rgb = tanh(O.rgb / 1e4);

  if(z<zMax) {
  }
}