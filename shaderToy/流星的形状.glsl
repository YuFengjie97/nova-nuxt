// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
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
  vec3 Z = rd;

  vec3 col = vec3(0);
  vec3 p = vec3(0);
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    // float d = sdBox(p-vec3(4,0,0), vec3(4.,.0,.0));
    // d = max(0.,d);
    float len = 7.;
    float d = length(p-vec3(clamp(p.x,0.,len),0,0));

    vec3 c = 1.1+sin(vec3(3,2,1)+p.z);
    float r = S(len,0.,p.x)*3.;
    // float r = clamp(exp(-p.x+2.),0.,4.);
    col += pow(r/d,2.)*c;


    if(d<EPSILON || z>zMax) break;
    z += d;
  }
  // col *= exp(-p.x);

  col = tanh(col / 1e2);

  O.rgb = col;
}