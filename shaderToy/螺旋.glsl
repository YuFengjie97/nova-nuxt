#iChannel0 "./pic/noise_256.png"

#define PI 3.1415926
#define T iTime

float noise2(vec2 p){
  float d = texture(iChannel0, p).r;
  return d;
}


float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
vec2 randomGradient(vec2 p){
  float a = hash(p)*PI*2.;
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
  float a = 1.;
  float f = 1.;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    // n += noise2(p*f*.005)*a;
    n += noise(p*f)*a;
    f *= 2.;
    a *= .5;
  }
  return n;
}


float domainWarping(vec2 p){
  vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                  fbm( p + vec2(1.2,1.3) ) );
  return fbm( p + 4.0*q );
  // vec2 q = vec2( fbm( p + vec2(.0,.0) ),
  //                fbm( p + vec2(2.2,2.3) ) );

  // vec2 r = vec2( fbm( p + .5*q + vec2(2.0, 4.0) ),
  //                fbm( p + .5*q + vec2(1.2,1.3) ) );

  // return fbm( p + 4.*r );
}

mat2 rotate(float v){
  float c = cos(v);
  float s = sin(v);
  return mat2(c,-s,s,c);
}

// https://www.shadertoy.com/view/ldBGDc
float spiral(vec2 m) {
	float r = length(m);
	float a = atan(m.y, m.x);
	float v = sin(200.*(r-0.01*a)-T*.5);
	return clamp(v,0.,1.);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;

  float di = log(length(uv))*1.5;
  float c = cos(di*3.)*.2;
  float s = sin(di*3.)*.2;
  mat2 r = mat2(c,-s,s,c);

  float n = domainWarping(uv*r*.7
                    +vec2(domainWarping(uv*rotate(T*.06+3.5)),
                          domainWarping(uv*rotate(T*.06+7.3))
                          )*.1
                    );

  vec3 col = sin(vec3(3,2,1)+n*15.)*.5+.5;
  O.rgb += n*col*4.;
}