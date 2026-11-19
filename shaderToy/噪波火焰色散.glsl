#iChannel0 "./pic/rock.png"
#define T iTime
#define PI 3.1415926

float noise(vec2 p){
  return texture(iChannel0, p).r;
}


vec2 rand2(in vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

// voronoi distance noise, based on iq's articles
float voronoi(in vec2 x){
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

float fbm(vec2 p){
  float f = 1.;
  float a = 1.;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    n += noise(p*f)*a;
    f*=2.;
    a*=.5;
  }
  return n;
}

float domainWarping(vec2 p){
  float n1 = fbm(p+vec2(.3,.4));
  float n2 = fbm(p+vec2(.1,.2));
  return fbm(p+5.*vec2(n1,n2));
}


float blender(vec2 uv){
  float ang  = atan(uv.y,uv.x) / PI;
  float ang2 = atan(uv.y,-uv.x)/PI;

  float dist = length(uv);
  vec2 p = vec2(ang, dist);
  vec2 p2 = vec2(ang2, dist);

  float n1 = domainWarping(p *.03-vec2(0,T*.01));
  float n2 = domainWarping(p2*.03-vec2(0,T*.01)+vec2(.2,.3));

  float mask  = 1.-smoothstep(1.,0.,abs(ang));
  float mask2 = 1.-smoothstep(1.,0.,abs(ang2));

  n1 = n1 - mask;
  n2 = n2 - mask2;
  return max(n1, n2);
  // return n1;
}

float pattern(vec2 p){
  float n = blender(p);
  float d = abs(length(p)-.5-n*.1);
  // d = pow(.01/max(0.001, d), 1.);
  d = smoothstep(.02, 0., d-.04);

  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;


  float e = .02;
  float r = pattern(uv);
  float g = pattern(uv*(1.-e));
  float b = pattern(uv*(1.+e));
  O.rgb = vec3(b,r,g)*4.;


  // O.rgb += r;


  // float dx = dFdx(r);
  // float dy = dFdy(r);
  // float e = .01;
  // float dx = pattern(uv+vec2(e,0))-r;
  // float dy = pattern(uv+vec2(0,e))-r;
  // vec2 dir = normalize(vec2(dx,dy));
  // float ang = atan(dir.y, dir.x);
  // vec3 col = sin(vec3(3,2,1)+ang*1.)*.5+.5;
  // O.rgb += col;
}