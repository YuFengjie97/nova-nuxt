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


// https://iquilezles.org/articles/voronoilines/
/*
oA 最小距离特征点
oB 次小距离特征点
*/
vec2 voronoi(vec2 uv, out vec2 oA, out vec2 oB){
  
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  // x分量代表当前像素距离特征点的最小距离,y代表次小距离
  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+T)*.3+.3;
    float d1 = length(nei+pos-uvf);
    /*
    距离小于最小距离,
    次小距离更新为现在的"最小距离"
    最小距离更新

    距离小于次小距离,
    次小距离更新
    */
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
      oA = pos;
    }else if(d1 < min_d.y){
      min_d.y = d1;
      oB = pos;
    }
  }
  }

  return min_d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb = vec3(0);
  O.a = 1.;

  // uv = vec2(atan(uv.y,uv.x), log(length(uv)));
  // uv.x = sin(uv.x*6.)/6.;
  uv *= 4.;

  vec2 a = vec2(0);
  vec2 b = vec2(0);
  vec2 d = voronoi(uv, a, b);

  float edge = d.y - d.x;  // 减去值配合发光半径,营造出立体感
  // float edge = dot(.5*(a+b),normalize(b-a));  // iq文章倒数第二步,我不理解,图案是破碎的,不是这么用?


  vec3 c = s1(vec3(3,2,1)+a.x*20.);

  O.rgb += edge*c*2.+pow(.1/(edge-.5),2.)*c;
}