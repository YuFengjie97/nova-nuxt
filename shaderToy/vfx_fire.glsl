// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
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

// 3D 柏林噪音
float hash13(vec3 p3)
{
	  p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 randomGradient(vec3 p){
  float the = hash13(p)*TAU;
  float phi = hash13(p+vec3(3,2,1))*TAU;
  return vec3(sin(the)*cos(phi), sin(the)*sin(phi), cos(the));

  // float z = hash13(p)*2.0 - 1.0;        // 均匀分布在 [-1,1]
  // float a = hash13(p+vec3(3,2,1)) * TAU; 
  // float r = sqrt(1.0 - z*z);
  // return vec3(r*cos(a), r*sin(a), z);
}

float noise(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);

  vec3 g000 = randomGradient(i+vec3(0,0,0));
  vec3 g100 = randomGradient(i+vec3(1,0,0));
  vec3 g010 = randomGradient(i+vec3(0,1,0));
  vec3 g001 = randomGradient(i+vec3(0,0,1));
  vec3 g011 = randomGradient(i+vec3(0,1,1));
  vec3 g101 = randomGradient(i+vec3(1,0,1));
  vec3 g110 = randomGradient(i+vec3(1,1,0));
  vec3 g111 = randomGradient(i+vec3(1,1,1));

  float v000 = dot(g000, f-vec3(0,0,0));
  float v100 = dot(g100, f-vec3(1,0,0));
  float v010 = dot(g010, f-vec3(0,1,0));
  float v001 = dot(g001, f-vec3(0,0,1));
  float v011 = dot(g011, f-vec3(0,1,1));
  float v101 = dot(g101, f-vec3(1,0,1));
  float v110 = dot(g110, f-vec3(1,1,0));
  float v111 = dot(g111, f-vec3(1,1,1));

  // vec3 u = smoothstep(0.,1.,f);
  vec3 u = f*f*f*(f*(f*6.0 - 15.0) + 10.0);


  float mx1 = mix(v000, v100, u.x);
  float mx2 = mix(v010, v110, u.x);
  float mx3 = mix(v001, v101, u.x);
  float mx4 = mix(v011, v111, u.x);
  float my1 = mix(mx1, mx2, u.y);
  float my2 = mix(mx3, mx4, u.y);
  float mz = mix(my1, my2, u.z);
  return mz;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += noise(p*fre)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

// float fbm(vec3 p){
//   // p*=4.;
//   float amp = 1.;
//   float fre = 1.;
//   float n = 0.;
//   for(float i =0.;i<5.;i++){
//     n += abs(dot(cos(p), vec3(.12,.15,.18)));
//     amp *= .5;
//     fre *= 2.;
//   }
//   return n;
// }

vec3 Tonemap_ACES(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (x * (a * x + b)) / (x * (c * x + d) + e);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,2.,-7.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 20.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<40.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    // p = mix(p, vec3(fbm(p*2.+vec3(0,T*10.,0))), vec3(.1));

    float n = fbm(p*vec3(1,.7,1)*.6+vec3(0,-T*3.,T));

    vec3 q = p;
    // q.xz *= rotate(q.y*4.);
    q = mix(q, vec3(n), .2);
    // n = clamp(n,0.,1.);
    // vec3 q = p;
    // q += n;
    float d = length(q*vec3(1,.7,1)-vec3(0,1.5,0)) - 2.4;
    d += n*1.1;

    d = abs(d)*.5 + .01;
    // d = max(EPSILON,d);

    
    float glow = pow(.6/d,2.);
    
    float gradient_range = S(0.,15.,length(q));
    vec3 c = mix(vec3(2,0,0), vec3(4,4,0), gradient_range);
    // vec3 c = mix(s1(vec3(3,2,1)+T), s1(vec3(2,4,8)+T), gradient_range);


    col += c * glow;

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 6e3);
  O.rgb = col;
}