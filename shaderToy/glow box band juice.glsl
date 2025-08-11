//https://www.shadertoy.com/view/t3KXR3

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define st(a,b) (sin(T*a+b)*.5+.5)

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

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float easeOutElastic(float x) {
  const float c4 = (2. * PI) / 3.;
  float v = pow(2., -10. * x) * sin((x * 10. - 0.75) * c4) + 1.;
  return clamp(v, 0., 1.);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O *= 0.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec4 col = vec4(0,0,0,1);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    p.xz *= rotate(T*.5);
    p.yz *= rotate(T*.5);


    vec3 q = p;
    float ease = 1./easeOutElastic(st(2.,0.));
    q *= ease;
    
    float d = sdBox(q, vec3(2));

    q = abs(p);
    q *= 1./easeOutElastic(st(2.,.2));
    
    float d1 = length(q-vec3(3.))- 1.;
    d = min(d, d1);

    d = abs(d) + .06;
    // d = max(0., d);

    vec3 c = sin(vec3(3,2,1)+q.x+q.y+q.z+ease*4.)*.5+.5;
    col.rgb += pow(.4/d, 4.) * c * S(0., .1,(sin((q.x+q.y+q.z+ease*4.)*4.)/4.));

    
    if(d<EPSILON || z>zMax) break;
    z += d * .2;
  }

  col.rgb = tanh(col.rgb / 1e3);

  O = col;
}