// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/发光粒子/bufferA.glsl"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec3 hash31(float p){
  float o1 = 4.*(cos(.1+T*4e-2)/8.);
  float o2 = 4.*(cos(.2+T*4e-2)/8.);
  float o3 = 4.*(cos(.3+T*4e-2)/8.);
  vec3 s = vec3(o1,o2,o3);
  vec3 p3 = cos(p*s+T)*.5+.5;
  return p3;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  float glow = 0.;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.xz *= rotate(T);
    p.yz *= rotate(T);

    // if(iMouse.z>0.){
    //   p.xz *= rotate(m.x);
    //   p.yz *= rotate(m.y);
    // }

    float d = 1e4;
    float rng = 7.;
    float num = 20.;

    vec3 pos_last = vec3(0);
    for(float i =0.;i<num;i++){

      vec3 n = hash31(i);
      vec3 pos = n * rng - rng/2.;
      float d1 = length(p-pos) - .02;
      pos_last = pos;
      d1 = max(d1, 0.);
      d = min(d, d1);
    }

    col += pow((sin(vec3(3,2,1)+p.x+p.z)*.5+.5)*.4/d, vec3(4.));
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e2);

  // vec3 col_last = texture(iChannel0, I/R.xy).rgb*.7;
  // col += col_last;

  O.rgb = col;
}