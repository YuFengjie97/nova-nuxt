// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"


/*
leon的形状变化粒子效果:https://www.shadertoy.com/view/tljXWy
1.特殊的map
  会接受一个时间参数,来确定一个由时间控制的渲染周期
2.最顶层的时间
  t = iTime + frame + hash(rd)
  iTime可以控制总体的时间表现,速度或定义一个顶层周期
  frame由for循环提供,乘以系数来决定帧的渲染距离
  由rd产生的随机值,用来营造混乱的粒子效果
*/

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

float hash(vec2 p){
  return fract(sin(dot(p, vec2(4646.4116,7532.7226)))*7331.3339);
}
// float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

vec3 C = vec3(3,2,1);

float map(vec3 p, float t, out float tt){
  // 将时间t转换为某个周期的样子
  // 并且通过out传递给外部,因为我希望颜色的变化跟形变有某种关联
  tt = tanh(sin(t)*3.);

  float d = 1e4;
  float total = 4.;
  for(float i = 0.;i<1.;i+=1./total){
    p = abs(p);
    p -= vec3(1.3*i+.1);
    p.xy *= rotate(TAU/total+tt);
    p.xz *= rotate(TAU/total+tt);
    p.yz *= rotate(TAU/total+tt);
    float d1 = sdBoxFrame(p, vec3(2), i*.3+.02)+hash(p.xy)*.001; // 距离场+hash值是为了用噪点代替伪影
    d = min(d, d1);

    C += (dot(p,vec3(.1)) + i*.2)/total;
  }
  return d;
}


vec3 raymarch(vec3 ro, vec3 rd, float t){
  vec3 col = vec3(0);
  vec3 p;
  float z=0.;
  float d;
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy * PI * 2.;
  float tt = 0.;

  for(float i=0.;i<100.;i++){
    p = ro+rd*z;
    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    d = map(p, t, tt);
    d = max(0., d*.4);
    // d = abs(d)*.5+.01;

    z+=d;
    col += s1(C+tt*4.)/d;

    if(d<EPSILON || z>40.)break;
  }
  col = tanh(col / 4e3);

  return col;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 uv = (I*2.-iResolution.xy)/iResolution.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);

  // float t = fract(T*.5);

  float motion_frames = 3.;
  for(float m=0.;m<motion_frames; m++){

    // 选取的随机hash需要是sin这种带有连续特征的
    float n = hash(rd.xy);
    float t = T + m*.1 + n*.02;
    col += raymarch(ro, rd, t)/motion_frames;
  }


  O.rgb = col;
}