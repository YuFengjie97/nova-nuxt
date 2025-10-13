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

  // uv = vec2(atan(uv.y,uv.x), log(length(uv)));
  // uv.x = sin(uv.x*6.)/6.;

  float d = 1e10;
  vec2 uv2 = uv * 6.;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    // 思路是确定整个uv,然后根据每个邻居点的在整个uv下的位置来绘制
    // 最后的简化其实和第二种一样
    // vec2 nei = uvi + vec2(x,y);
    // vec2 n = sin(hash22(nei+T*.0001) * PI * 2.)*.5;
    // vec2 pos = nei + n;
    // float d1 = length(uv2 - pos - .5);
    // d = min(d, d1);

    // pos是邻居点id(uvi+nei)在当前格子的位置
    // length(pos-uvf) uvf理解为当前像素点,向量uvf-->pos
    // 即为当前像素点到目标点的距离
    // 因为是邻居格子,最后需要加上nei的平移
    // 总体为当前像素点(uvf)到邻居点(nei+pos)的距离(length)
    vec2 nei = vec2(x,y);
    vec2 pos = hash22(uvi+nei);
    float d1 = length(nei+pos-uvf);
    d = min(d, d1);
  }
  }

  // d = S(.1,0.,d);
  d = pow(.2/d,2.);

  O.rgb += d * s1(vec3(3,2,1)+length(uv)+T*2.);
}