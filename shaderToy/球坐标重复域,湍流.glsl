// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
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

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
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
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}


float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise(float v){
  float i = floor(v);
  float f = fract(v);
  float h1 = hash11(i);
  float h2 = hash11(i+1.);
  return mix(h1,h2,f);
}


// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	// vec3 cw = normalize(ta-ro);            // 相机前
	// vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	// vec3 cu = normalize( cross(cw,cp) );   // 相机右
	// vec3 cv = normalize( cross(cu,cw) );   // 相机上
  // return mat3( cu, cv, cw );

  vec3 front = normalize(ta - ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  return mat3(right, up, front);
}
float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  float t_path = mod(T, 60.);
  vec3 ro = vec3(0,4,-10.);
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  mat2 mx = rotate(T*.0);
  mat2 my = rotate(T*.0);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }


  vec3 col = vec3(0);
  float i = 0.;
  while(i++<80.){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;

    // 直角系 --> 球坐标
    vec3 q = p;
    float r = length(q);
    float the = acos(q.y/r);
    the = cos(the*4.);
    float phi = atan(q.z, q.x);
    phi = cos(phi*4.);
    r -= T*2.;

    // 球面坐标,并用cos重复R距离
    q = vec3(the, phi, cos(r));

    // 根据距离来形成的1D噪音,配合湍流扭曲形状
    float nt = noise(r*.1);
    q += cos(q.zxy*2.+nt*10.-T*1.);

    // 使用极角和方位角绘制的线条
    float d = length(q.xy)-.1;

    // 绘制重复球 
    {
      float d1 = length(q) - .3;
      d = smin(d, d1, .4);
    }

    // 去掉镜头前的部分,防止形状遮挡
    {
      float d2 = length(p-ro)-3.;
      d = max(d, -d2);
    }

    d = abs(d)*.3 + .01;


    col += s1(vec3(3,2,1)+dot(q, vec3(.8))+T) / d;

    z += d;
  }

  col = tanh(col / 1e3);

  O.rgb = col;
}