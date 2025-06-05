#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/particle_flow/bufferA.glsl"
#define num 10.
#define T iTime
#define speed 0.01
#define Pi 3.141596

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

vec2 hash22(vec2 p) {
    p = fract(p * vec2(5.3983, 5.4427));
    p += dot(p, p + 3.5453123);
    return fract(vec2(
        sin(p.x + p.y * 13.345),
        sin(p.y + p.x * 17.327)
    ) * 95.4337);
}

vec4 reset(vec2 I){
  vec4 res;
  res.xy = hash22(I+T);
  res.z = res.x * 36.15 + T;
  res.w = 0.;
  return res;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy/iResolution.y;  // 归一化的屏幕坐标

  if(I.x >= num || I.y >= num) return;

  for(float x=0.;x<num;x++){
    for(float y=0.;y<num;y++){
      if(iFrame <= 10) {
        O = reset(I);
      }else{
        vec2 prePos = texelFetch(iChannel0, ivec2(I), 0).xy;  // 之前的位置
        float a = noise(I+T*0.1)*Pi*2.;                       // 当前位置应该具有的速度方向
        vec2 vel = vec2(cos(a), sin(a));
        O.xy = prePos + vel * speed;                          // 运动并且存储
        
        // 越界重设位置
        if(O.x < -1.1 || O.x>1.1 || O.y<-1.1 || O.y > 1.1){
          O = reset(I);
        }
      }
    }
  }
}