
// 2D random numbers
vec2 rand22(in vec2 p)
{
	return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}
vec2 rand2(in vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

// voronoi distance noise, based on iq's articles
float voronoi(in vec2 x)
{
	vec2 p = floor(x);
	vec2 f = fract(x);
	
	vec2 res = vec2(8.0);
	for(int j = -1; j <= 1; j ++)
	{
		for(int i = -1; i <= 1; i ++)
		{
			vec2 b = vec2(i, j);
			vec2 r = vec2(b) - f + rand2(p + b);
			
      
      // float d = length(r);
      // float d = dot(r, r);

      // float d = abs(r.x) + abs(r.y);

			float d = max(abs(r.x), abs(r.y));

      // float p = 1.2;
      // float d = pow(pow(abs(r.x),p)+pow(abs(r.y),p), 1.0/p);

			
			if(d < res.x)
			{
				res.y = res.x;
				res.x = d;
			}
			else if(d < res.y)
			{
				res.y = d;
			}
		}
	}
	return res.y - res.x;
}

float voronoi2(in vec2 x) {
    vec2 p = floor(x);       // 当前格子
    vec2 f = fract(x);       // 格子内偏移

    float res = 8.0;         // 初始一个很大的值

    // 遍历 3x3 邻域格子（含自身）
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 b = vec2(i, j);
            vec2 r = vec2(b) - f + rand2(p + b); // 随机特征点偏移
            float d = dot(r, r);                 // 距离平方
            res = min(res, d);                   // 取最近距离
        }
    }
    return sqrt(res); // 开方还原真实距离
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I * 2. - R)/R.y;
  float d = voronoi(uv*2.);
  O.rgb += d;
}