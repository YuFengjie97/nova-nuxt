// 槐南一梦 https://www.shadertoy.com/view/3clyR2

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

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;
  float pix = 1./R.y;

  O.rgb *= 0.;
  O.a = 1.;

  // 2D下的测试
  // float ang = atan(uv.y, uv.x);
  // float n = 5.;
  // float doff = sin(ang  * n);
  // float d = length(uv) - (.4 + doff * .1);
  // d = S(4.*pix,0.,d);
  // O.rgb += d;


  // 3D raymarch
  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 20.;
  float z = .1;

  vec3 col = vec3(0);
  float glow = 0.;
  for(float i=0.;i<200.;i++){
    vec3 p = ro + rd * z;


    p.xz = rotate(p.y*.4+T)*p.xz;
    p.y *= .8;


    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    vec3 q = p;
    // float ang = acos(p.x/4.);
    float ang = atan(p.z, p.x);
    float n = 6.;
    float doff = sin(ang * n ); 

    float d = length(p) - (5. + doff * .6);

    // d = max(d, 0.);
    d = abs(d) + .1;

    vec3 c = (.5+.5*sin(vec3(3,2,1)+p.x));
    glow += pow(.1/d, 2.);
    col += glow * c;

    if(d<EPSILON || z>zMax) break;
    z += max(d*.1, EPSILON*2.);
  }

  col = tanh(col / 3e3);

  O.rgb = col;
}