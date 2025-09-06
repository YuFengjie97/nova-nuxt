// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)

const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float sdBox(vec3 p){
  p = abs(p);
  float d = max(p.x, max(p.y, p.z));
  return d;
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
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.yz *= rotate(radians(-30.));
    p.xz *= rotate(radians(-30.));

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    vec3 q = vec3(abs(atan(p.y,p.x)), length(p.xy), p.z);


    float sy = 1.;
    float idy = round(q.y / sy);
    float y = idy*sy;
    q.y -= y;

    q.x *= y;

    float sx = TAU / 5.;
    float idx = round(q.x/sx);
    float x = idx*sx;
    q.x -= x;

    // q.z += cos(idy+T*3.)*2.;   // 一动就完蛋

    float maxR = sy * .3;

    float d1 = sdBox(q)-maxR;
    float d2 = length(q) - maxR;
    float d = mod(idx+idy, 2.) == 0. ? d1 : d2;

    d = abs(d)*.7 + .01;
    // d = max(d, 0.);


    vec3 c = s1(vec3(3,2,1)+dot(p.xy, p.xy)*.1);
    // col += pow(.1/d, 2.) * c;   // 一发光就完蛋
    col += exp(-d/2.) * .1 * c;


    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  // col = pow(col, vec3(.4545));

  col = tanh(col * .4);

  O.rgb = col;
}