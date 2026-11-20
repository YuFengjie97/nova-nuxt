// 是用沃洛诺伊构造流场速度

#iChannel0 "./bufferA.glsl"


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

      float d = abs(r.x) + abs(r.y);

			// float d = max(abs(r.x), abs(r.y));

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

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;

  O.rgb *= 0.;


  if(iFrame<4){
    float s = 4.;
    float d = voronoi(uv*s);
    float e = .01;
    float dx = voronoi((uv+vec2(e,0))*s)-d;
    float dy = voronoi((uv+vec2(0,e))*s)-d;
    O.xy = normalize(vec2(dy,-dx));
  }else{
    O.xyz = texelFetch(iChannel0, ivec2(I), 0).rgb;
  }
}