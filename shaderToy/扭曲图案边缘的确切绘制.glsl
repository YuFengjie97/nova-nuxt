#define PI 3.141596
#define T iTime
#define S smoothstep
#define R iResolution.xy
#define pix 1./R.y

float f1(vec2 p){
  float r = p.y;
  float a = p.x;

  float d = r - 1. + sin(3.*a+2.*pow(r,2.))/2.;
  return abs(d);
}

float f2(vec2 p){
  float d = f1(p);
  vec2 h = vec2( 0.01, 0.0 );
  vec2 g = vec2( f1(p+h.xy) - f1(p-h.xy),
                f1(p+h.yx) - f1(p-h.yx) )/(2.0*h.x);
  return abs(d) / length(g);
}


float f3(vec2 p){
  float d = f1(p);
  vec2 g = vec2(dFdx(d),dFdy(d))/(10.*pix);
  return abs(d) / length(g);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv *= 2.;
  
  vec2 p = vec2(atan(uv.y,uv.x),length(uv));

  // float d = f1(p);
  // float d = f2(p);
  float d = f3(p);
  d = S(0.1,0.,d);
  O.rgb+=d;

}