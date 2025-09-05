#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

// 对https://www.shadertoy.com/view/3fByWG 火焰形状解析

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += noise(p*fre)*amp;
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  float n = fbm(uv*.1+vec2(0., -T*.07));

  float mask = S(-0.5,0.8,uv.y);                         // 遮罩,标定某些特征的范围
  uv.x += sin(uv.y*(4.+(n*4.))-T*4.) * n * mask * .2;    // 主体扭动由sin控制,然后加点随机(频率,振幅,你喜欢就好)

  float d = sdSegment(uv, vec2(0), vec2(0,.8));          // 选择一个合适的基础形状,这里是线段

  float r = (1.-mask)*(n*.2+.1);                         // 根据遮罩来控制半径,将线段塑造成水滴状,在此基础上再加点随机
  d -= r;
  vec3 c = pow(.02/d, 2.) * vec3(1.,0,0);      // 给外焰加点发光
  float rg = S(-.05,-.06,d);                     // 内焰范围
  O.rgb = mix(c, vec3(1.,1.,0), rg);
}