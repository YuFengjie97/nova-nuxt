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
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  uv = vec2(atan(uv.y,uv.x), log(length(uv)));
  uv.x = sin(uv.x*6.)/6.;

  vec2 uv2 = uv * 6.;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  vec2 min_p = vec2(0);

  // x分量代表当前像素距离特征点的最小距离,y代表次小距离
  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+T)*.3+.3;
    float d1 = length(nei+pos-uvf);
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
      min_p = pos;
    }else if(d1 < min_d.y){
      min_d.y = d1;
    }
  }
  }
  float edge = min_d.y - min_d.x;
  edge = pow(.1/edge, 2.);
  vec3 c = s1(vec3(3,2,1)+min_p.x*10.);

  O.rgb += edge * c;
}