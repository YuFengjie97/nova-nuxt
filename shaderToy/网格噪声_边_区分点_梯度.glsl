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

// 最小距离特征点的位置
vec2 min_p = vec2(0);

float f(vec2 uv){
  uv = vec2(atan(uv.y,uv.x), log(length(uv)));
  uv.x = sin(uv.x*6.)/6.;

  vec2 uv2 = uv * 2.;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

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
  return edge;
}

// https://iquilezles.org/articles/distance/
float grad(vec2 p){
  float d = f(p);
  vec2 h = vec2( 0.01, 0.0 );
  vec2 g = vec2( f(p+h.xy) - f(p-h.xy),
                 f(p+h.yx) - f(p-h.yx) )/(2.0*h.x);
  return abs(d) / length(g);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  float edge = grad(uv);
  
  edge = pow(.02/edge, 2.);
  vec3 c = s1(vec3(3,2,1)+dot(min_p,min_p)*4.);

  O.rgb += edge * c;
}