// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture1.jpg"
#iChannel0 "./pic/noise_256.png"

#define TAU 6.283185
#define PI 3.1415926
#define T iTime
#define SPEED .4



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

float noise2(vec2 p){
  return texture(iChannel0, p).r;
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


float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  float f = 1.;
  // p.y -= T * SPEED;
  for(float i =0.;i<3.;i++){
    // n += noise2(p*f*.01)*amp;
    // n += noise(p*f)*amp;
    // n += voronoi(p*f)*amp;
    n = max(n, voronoi(p*f)*amp);
    amp *= .5;
    f *= 2.;
  }
  return n;
}


float domainWarping(vec2 p){
  // return noise2(p*.2);
  // vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
  //                 fbm( p + vec2(1.2,5.3) ) );
  // return fbm( p + 10.0*q );
  vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                 fbm( p + vec2(5.2,2.3) ) );

  vec2 r = vec2( fbm( p + .1*q + vec2(8.7,2.2) ),
                 fbm( p + .1*q + vec2(3.3,1.8) ) );

  return fbm( p + 4.2*r );
}

vec3 palette(float v){
  return sin(vec3(1,2,3)+v)*.5+.5;
}
vec3 dunhuangGradient(float v) {
    v = clamp(v, 0.0, 1.0);

    vec3 colors[10];
    colors[0] = vec3(0.22, 0.53, 0.40); // 石绿
    colors[1] = vec3(0.15, 0.35, 0.55); // 石青
    colors[2] = vec3(0.78, 0.52, 0.20); // 赭石
    colors[3] = vec3(0.75, 0.25, 0.15); // 朱砂
    colors[4] = vec3(0.88, 0.35, 0.20); // 朱红
    colors[5] = vec3(0.55, 0.20, 0.12); // 铁红
    colors[6] = vec3(0.92, 0.88, 0.80); // 蛤粉
    colors[7] = vec3(0.12, 0.10, 0.10); // 墨黑
    colors[8] = vec3(0.85, 0.70, 0.30); // 泥金
    colors[9] = vec3(0.90, 0.72, 0.58); // 肤色

    float scaled = v * 9.0;
    int i = int(floor(scaled));
    float t = fract(scaled);

    int next = min(i + 1, 9);
    return mix(colors[i], colors[next], t);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;

  float dist  = length(uv);

  // scale and speed
  float x = dot(normalize(uv), vec2(1.,0.));
  float y = dot(normalize(uv), vec2(0.,1.));
  vec2 p = vec2(x,y);

  float ang = atan(uv.y, uv.x)/PI;
  vec2 q = vec2(ang, dist);

  uv*=2.;

  // float d = fbm(uv*2.*vec2(1., 1.));
  float d = smoothstep(.04,0.,voronoi(uv)-.03);
  d += smoothstep(.06,0.,voronoi(uv*1.7)-.01)*.7;
  float d1 = smoothstep(.11, 0.1, noise2(uv*.01+T*.02))*2.+.5;


  O.rgb += d * d1;

}