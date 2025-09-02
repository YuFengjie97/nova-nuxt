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

float noise(vec3 p){
  float n1 = texture(iChannel0, p.xy).r;
  float n2 = texture(iChannel0, p.xz).r;
  return mix(n1, n2, fract(p).x);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += noise(p);
    // n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
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

  vec3 col = vec3(0);
  for(float i=0.;i<50.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float d = length(p)-4.;
    z += d;

    // d = p.y;
    d = sdBox(p, vec3(2.));

    float a = 1.;
    for(float i=0.;i<4.;i++){
      p.yz *= rotate(2.);
      d += a*dot(cos(p+T), sin(p.yxz));
      a *= .5;
    }
    d = abs(d) + .1;
    // d = max(0., d);

    
    vec3 c = 2.+sin(vec3(3,2,1)+p.y+p.z);
    col += c * pow(2. / d, 2.);

    if(d<EPSILON) break;
  }

  O.rgb = tanh(col / 4e2);;
}