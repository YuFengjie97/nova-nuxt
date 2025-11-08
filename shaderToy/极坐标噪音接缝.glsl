// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256.png"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_256x256_rgb.png"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/texture/vfx_tail/tail_2.png"

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

  // vec3 a = vec3(0.5, 0.5, 0.5);
  // vec3 b = vec3(0.5, 0.5, 0.5);
  // vec3 c = vec3(2.0, 1.0, 0.0);
  // vec3 d = vec3(0.5, 0.2, 0.25);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}


// David Hoskins hash function
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}


vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}


// float fbm(vec2 p){
//   float amp = 1.;
//   float n = 0.;
//   float fre = 1.;
//   for(float i =0.;i<3.;i++){
//     // n += voronoise(p*fre)*amp;
//     n += noise(p*fre)*amp;
//     amp *= .5;
//     fre *= 2.;
//   }
//   return n;
// }

// float fbmWrap(vec2 p){
//   vec2 q = vec2(
//                 fbm(p+vec2(13.24,42.74)),
//                 fbm(p+vec2(51.16,17.93))
//                 );
//   // float n = fbm(p);
//   // vec2 q = vec2(n, n*33.22+11.45);

//   float d = fbm(q);
//   return d;
// }

float remap01(float v, float vmin, float vmax){
  return clamp(max(0.,v-vmin)/(vmax-vmin),0.,1.);
}

vec2 toPolar(vec2 uv){
  return vec2((atan(uv.y, uv.x)), length(uv));
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-vec2(R.x/2.,R.y/2.))/R.y;

  O.rgb *= 0.;
  O.a = 1.;


  // vec2 uv2 = toPolar(uv);
  vec2 uv2 = uv;


  float period = 2.0;
  float t = T;

  float t1 = mod(t,           period);
  float t2 = mod(t+period*.5, period);

  float n1 = noise(uv2*5.+vec2(0, t1/period)*5.);
  float n2 = noise(uv2*5.+vec2(0, t2/period)*5.);
  // float n = mix(n1, n2, S(0.5,1.,t1/period));
  float n = mix(n1, n2, 1.5);
  // float n = n2;


  O.rgb += S(30./R.y,0.,n);

  #if 0
  vec2 uv2 = toPolar(uv);
  float n = noise(uv2+T);
  // uv = mix(uv, vec2(n), .6);

  vec2 off = vec2(0., sin(T*.2)*10.);
  vec2 scale = vec2(3.,.9);
  float n1 = fbm(toPolar(uv)*scale + off);
  float n2 = fbm(toPolar(uv*rotate(PI))*scale + vec2(4) + off);
  

  // float d = n1;
  float range = clamp(abs(atan(uv.y,-uv.x)), 0., 1.);
  float d = mix(n2, n1, range);
  // d = range;
  

  vec3 col = s1(vec3(3,2,1)+atan(uv.y,uv.x)+length(uv)*10.) * 5.;
  O.rgb += col*d;
  #endif
}