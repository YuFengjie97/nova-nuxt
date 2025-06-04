#define T iTime

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2
    const float K2 = 0.211324865; // (3-sqrt(3))/6

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a,a), dot(b,b), dot(c,c)), 0.0);

    vec3 n = h * h * h * h * vec3(
        dot(a, hash(i + 0.0)),
        dot(b, hash(i + o)),
        dot(c, hash(i + 1.0))
    );

    return dot(n, vec3(70.0));
}


float fbm(vec2 p){
  float a = .5;
  float n = 0.;

  for(float i=0.;i<4.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;
  // 背景色
  O.rgb = vec3(0.69,0.8,0.54);
  O.a = 1.;
  float n,d,s,aa;

  // 背部大面积涟漪
  n = noise(uv * vec2(12.,1.)+vec2(0,T*1.5));
  s = smoothstep(0.2,0.1,abs(n));
  O.rgb = mix(O.rgb, vec3(0.81,0.93,0.66), s);


  // 底部阴影
  n = noise(uv*vec2(6.,.5)+vec2(0,T));
  float d1 = uv.y-0.2 + n*0.6;
  s = smoothstep(0.2,0.1,d1);
  O.rgb = mix(O.rgb, vec3(0.52,0.61,0.41),s);


  // 底部阴影的阴影
  d1 = abs(uv.y-sin(7.*uv.x+T*3.)/20.-0.2);    // 距离场
  s =  smoothstep(0.1,0.,d1);                   // 通过距离场限制范围
  n = noise(uv*vec2(40.,1.5)+vec2(T));         // 噪音值缩放
  s *= n*smoothstep(0.,0.5,sin(uv.x*4.-0.8));     // 在区域范围中,使用噪音进行采样,并且通过uv.x遮挡范围
  s = smoothstep(0.2,0.25,s);                  // 具体形状                
  O.rgb = mix(O.rgb, vec3(0.44,0.5,0.32), s);

  // 中部高亮
  d = abs(uv.y-sin(30.*uv.x+T*3.)/20.-0.5);
  s = smoothstep(0.2,0.,d);
  s *= n*smoothstep(0.,0.5,sin(uv.x*6.-2.));                                     
  s = smoothstep(0.1,0.2,s);               
  O.rgb = mix(O.rgb, vec3(1,1,0.85), s);


  // 顶部高亮
  d1 = abs(uv.y-sin(20.*uv.x+T*4.)/40.-0.8);
  s = smoothstep(0.15,0.,d1);
  s *= n*smoothstep(0.,0.1,sin(uv.x*8.));                                     
  s = smoothstep(0.05,0.2,s);               
  O.rgb = mix(O.rgb, vec3(1,1,0.95), s);


  // 底部浪
  n = fbm(uv+T*0.4);
  d1 = uv.y-sin(uv.x*5.+T*5.)/25. - n*0.1;  // sin曲线确定距离场范围,额外加一点噪音扰乱
  s = smoothstep(0.1,0.,d1);
  s = s + n*s;                              // n*s限制范围, s+ 阈值扩大隐藏掉fbm中的空心,只让空心出现在smoothstep的渐变范围里
  s = clamp(s,0.,1.);
  float s1 = smoothstep(0.1,0.21,s);        // s通过n*s+s只有渐变部分是可参考的,其余地方都是1了,这里数值参考意义不大
  O.rgb = mix(O.rgb, vec3(0.87,0.96,0.76),s1);
  float s2 = smoothstep(0.5,0.51,s);
  O.rgb = mix(O.rgb, vec3(0.76,0.86,0.67),s2);
}