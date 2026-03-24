// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"


#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)

// #define P(z) (vec3(cos((z)*.011)*16.+cos((z) * .012)  *24., \
//                    cos((z)*.01)*4., (z)))

#define P(z) (vec3(cos(z*.02)*20., sin(z*.04)*10., z))

const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  return vec2(cos(a), sin(a));
}

vec3 texture(vec3 p){
  // uv = abs(uv);
  vec2 uv = p.xz*.1;
  for(float s = 1.;s<20.;s++){
    uv += abs(fract(uv.yx*s-T*1.)-.5)/s;
  }
  float d = dot(uv*10., vec2(.1))*2.;
  return s1(vec3(3,2,1)+d*3.);
}


vec3 light = vec3(0);
vec3 tex = vec3(0);
float map(vec3 p){
  p.xy -= P(p.z).xy;
  
  float d = 1e10;

  p = abs(p);
  float d_tun = min(32.-p.x - p.y, 14.-p.y);
  d = min(d, d_tun);
  if(d_tun<.1){
    tex = texture(p);
  }

  float d_line = length(p.xy-10.)-.4;
  d = min(d, d_line);
  {
    d_line = abs(d_line) * .1 + .01;
    // light += .001*palette(p.z*.01+T)/d_line;
    light += .001*s1(vec3(3,2,1)+p.z*.04+T) / d_line;
  }

  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 rd = normalize(vec3(uv, 1.));

  float z = .1;


  vec3 col = vec3(0);
  vec3 C = vec3(3,2,1);
  float i=0.;
  vec3 p,ro;
  while(i++<100.){
    vec3 q = P(T*40.);
    ro = q;
    p = ro +  rd * z;

    float d = map(p);
    
    // col += s1(C+p.z*.1)/d;
    // col += palette(p.z*.01)/d;
    col += (.1 + light + tex*.1) / max(d, .01);
    
    z += d;
  }

  col = tanh(col / 2e3);

  O.rgb = col;
}