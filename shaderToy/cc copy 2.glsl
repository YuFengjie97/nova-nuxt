#iChannel0 "./pic/noise_256.png"


#define TAU 6.283185
#define PI 3.1415926
#define T iTime


float noise2(vec2 p){
  return texture(iChannel0, p).r;
}


float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
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


float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  float f = 1.;
  for(float i =0.;i<6.;i++){
    // n += noise2(p*f*.01)*amp;
    n += noise(p*f)*amp;
    amp *= .5;
    f *= 2.;
  }
  return n;
}


float domainWarping(vec2 p){
  vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                  fbm( p + vec2(1.2,5.3) ) );
  return fbm( p + 10.0*q );
  // vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
  //                fbm( p + vec2(5.2,2.3) ) );

  // vec2 r = vec2( fbm( p + .1*q + vec2(8.7,2.2) ),
  //                fbm( p + .1*q + vec2(3.3,1.8) ) );

  // return fbm( p + 4.2*r );
}


mat2 rot2(float v){
  float c = cos(v);
  float s = sin(v);
  return mat2(c,-s,s,c);
}
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise1D(float x) {
  float i = floor(x);
  float f = fract(x);
  float u = f * f * (3.0 - 2.0 * f); // smoothstep 插值
  return mix(hash11(i), hash11(i + 1.0), u);
}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}


vec2 trans(vec2 p){
  return hash22(p)*1.;
}

const float G = 1.;

void check(inout float d, vec2 p, vec2 n){
  vec2 s2 = trans(n)+.5+n;
  float d2 = length(p-s2);
  d = min(d, d2);
}

float map(vec2 p){
  vec2 i = floor(p/G);
  vec2 s1 = trans(i)+.5+i;
  float d = length(p-s1);

  for(float s = 1.; s<6.;s++){
    check(d, p, i + s*vec2(1,0));
    check(d, p, i + s*vec2(-1,0));
    check(d, p, i + s*vec2(0,1));
    check(d, p, i + s*vec2(0,-1));

    check(d, p, i + s*vec2(-1,-1));
    check(d, p, i + s*vec2(1,1));
    check(d, p, i + s*vec2(-1,1));
    check(d, p, i + s*vec2(1,-1));
  }


  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float pix = 1./R.y;
  

  O.rgb *= 0.;

  float d = map(uv*2.);

  O.rgb += d*.2;
}