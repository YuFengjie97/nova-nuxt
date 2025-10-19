// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_2.png"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
#define pix (1./iResolution.y)

const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}


float fbm(vec2 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(fre*p)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

// iq sdf function
// 用来绘制点和线的基元
float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float sdRhombus( in vec2 p, in vec2 b ) 
{
    p = abs(p);
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*vec2(1.0-h,1.0+h) );
    return d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}

float sdTriangleIsosceles( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
}

float el_point(vec2 p){
  float d = sdRhombus(p, vec2(.2,.1));
  return d;
}

float el_line(vec2 p, float len){
  float d = sdRhombus(p, vec2(.2,.1));
  float d1 = sdTriangleIsosceles(p-vec2(.1,-.6), vec2(0.1, .6));
  d = min(d, d1);
  return d;
}

float el(vec2 p, vec2 id){
  id*=33.69; // 噪音整体缩放

  float n_t = fract(T/20000.);
  id+=n_t*vec2(33.11,83.97);

  // 位置,角度,长度的噪音基础值
  vec2 n_pos = vec2(noise(id), noise(id+vec2(33.13,11.56)));
  float n_a = noise(id+vec2(91.42,53.86));
  float n_len = noise(id+vec2(63.92));
  float d = 0.;

  // 基元位置,在当前uv中分3x3个格子来确定位置
  vec2 pos = floor(n_pos*3.)*.33;
  p -= pos;

  // 根据长度来确定要绘制点还是线
  if(n_len<.4){
    d = el_point(p);
  }else{
    float ang = floor(n_a*8.)/8.*TAU;
    d = el_line(p*rotate(ang), n_len);
  }

  // 为sdf距离场添加噪音,让点线基元的边缘变化随机一些
  float n = noise(p*.14);
  d += n*.06;

  return d;
}


float char(vec2 p, vec2 id){
  // 空白格
  if(mod(id.x,2.)==0.||mod(id.y,2.)==0.){
    return 1e10;
  }

  float d = 1e10;
  for(float i=0.;i<3.;i++){
    float d1 = el(p, id*(23.11*i));
    d = min(d, d1);
  }
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  uv *= 6.;
  vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);

  vec3 col = vec3(0);

  // 测试网格
  // if(abs(uvf.x)<.01||abs(uvf.y)<.01){
    // col = vec3(1,0,0);
  // }

  O.rgb *= 0.;
  O.a = 1.;

  float ch = 1e10;
  for(float x=-1.;x<=1.;x++){
  for(float y=-1.;y<=1.;y++){
    vec2 nei = vec2(x,y);
    /*  网格噪音的技巧
        注意不要在封装的sdf中使用smoothstep
        应该在9个邻居的并集后再smoothstep
    */
    float ch1 = char(uvf-nei, uvi+nei);
    ch = min(ch, ch1);
  }
  }
  ch = S(10.*pix,0.,ch);
  col += ch;

  O.rgb = col;
}