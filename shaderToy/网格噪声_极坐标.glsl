#define T iTime
#define PI 3.141596
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)


// David Hoskins hash function
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  uv = vec2(atan(uv.y,uv.x), log(length(uv)));
  uv.x = sin(uv.x*6.)/6.;

  float d = 1e10;
  vec2 uv2 = uv * 6.;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = uvi + vec2(x,y);

    vec2 pos = nei + sin(hash22(nei+T*.0005) * PI * 2.)*.5;
    float d1 = length(uv2 - pos - .5);
    d = min(d, d1);
  }
  }

  // d = S(.1,0.,d);
  d = pow(.2/d,2.);

  O.rgb += d * s1(vec3(3,2,1)+length(uv)+T*2.);
}