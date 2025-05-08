#define maxIter 100.

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*.5)/R.y;
  vec3 col = vec3(0.);

  vec2 m_o = (iMouse.xy - R*.5) / R.y;
  vec2 m = m_o;
  vec2 uv_o = uv;

  float zoom = 5.;
  // 因为一开始就被缩放了,uv和m需要一同被缩放
  uv *= zoom;
  m *= zoom;
  
  if(iMouse.z > 0.) {
    // 局部放大
    //zoom = .1;
    zoom = (sin(iTime) * 0.5 + 0.5) * 0.2 + 0.01;
    
    // 放大后的uv坐标
    uv = uv_o * zoom;
    // 放大后的鼠标坐标
    vec2 m2 = m_o * zoom;
    // 将放大后的点击位置移动到鼠标处
    uv -= (m2 - m);

    
  }


  // 虚数c
  vec2 c = uv;
  // z初始值为0,在复数平面上为0+0i
  vec2 z = vec2(0.);

  float i = 0.;

  for(;i<maxIter;i+=1.){
    // z的平方(x+yi)的平方
    vec2 z2 = vec2(z.x*z.x-z.y*z.y, 2.*z.x*z.y);
    z = z2 + c;

    // 判断c是否属于曼德波集合
    if(dot(z2, z2) > 4.) break;
  }
  
  float d = i / maxIter;
  col = vec3(3.,2.,1)*d;

  // float cro = abs(uv.x) * abs(uv.y);
  // cro = smoothstep(0.01,0.,cro);
  // col = mix(col, vec3(1.,0.,0.), cro);

  O = vec4(col, 1.);
}