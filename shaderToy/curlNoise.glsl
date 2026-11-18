#iChannel0 "./pic/noise_64.png"
#iChannel1 "./pic/rock.png"

#define T iTime
#define TAU 6.283185

float noise2(vec2 p){
  return texture(iChannel1, p).r;
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
  float a = 1.;
  float f = 1.;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    n += noise(p*f)*a;
    f *= 2.;
    a *= .5;
  }
  return n;
}

float domainWarping(vec2 p){
  vec2 q = vec2( fbm( p + vec2(0.1,0.2) ),
                 fbm( p + vec2(0.2,0.1) ) );
  return fbm( p + 1.0*q );
  // vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
  //                fbm( p + vec2(.2,.3) ) );

  // vec2 r = vec2( fbm( p + .1*q + vec2(.7,.2) ),
  //                fbm( p + .1*q + vec2(.3,.8) ) );

  // return fbm( p + 10.*r );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  float pix = 1./R.y;

  float s = 1.;

  float d = domainWarping(uv*s);

  float dx,dy;
  vec2 dir;

  if(uv.x<0.){
    dx = dFdx(d);
    dy = dFdy(d);
    dir = vec2(dy, -dx);
  }else{
    float e = .01;
    dx = d-domainWarping(uv*s-vec2(e,0));
    dy = d-domainWarping(uv*s-vec2(0,e));
    dir = vec2(dy, -dx);
  }


  float ang = atan(dir.y, dir.x);

  d = fbm(dir);

  vec3 col = sin(vec3(3,2,1)+ang*1.)*.5+.5;

  O.rgb += col;
}