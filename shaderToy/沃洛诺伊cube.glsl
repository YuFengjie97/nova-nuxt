// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"

#iChannel0 "./pic/noise_256.png"

#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float noise(vec2 p){
  return texture(iChannel0, p).x;
}

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p*fre), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}
// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );

  // vec3 front = normalize(ta - ro);
  // vec3 up = vec3(0,1,0);
  // vec3 right = normalize(cross(front, up));
  // return mat3(right, up, front);
}


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

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,10.);
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 1.));

  float z = .0;


  mat2 mx = rotate(T*.1);
  mat2 my = rotate(T*.1);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }

  vec3 col = vec3(0);
  vec3 C = vec3(3,2,1);
  float i=0.;
  while(i++<40.){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;


    vec3 ap = abs(p);
    float b = sdBox(p, vec3(4.));

    float vn;
    vec3 q = p*.7;

    if (ap.x > ap.y && ap.x > ap.z) {
        vn = voronoi(q.yz);   // 左右面
    } else if (ap.y > ap.x && ap.y > ap.z) {
        vn = voronoi(q.xz);   // 上下面
    } else {
        vn = voronoi(q.xy);   // 前后面
    }

    float d = length(vec2(vn, b));
    d = max(.01, d*.6);

    
    col += s1(C+i*.2)/d;
    
    z += d;
  }

  col = tanh(col / 5e2);

  O.rgb = col;
}