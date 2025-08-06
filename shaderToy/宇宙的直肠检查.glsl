// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i=0.;i<5.;i++){
    n += amp*abs(dot(cos(p*fre), vec3(.06)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}
/**
镜头的时间线,对唯一时间点,映射一个位置
也是路径弯曲的规则,隧道的xy平移根据path.xy制定
*/
vec3 path(float v){
  return vec3(cos(v*.2+sin(v*.1))*4.,
              sin(v*.2+cos(v*.1))*4., v);
}

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  // vec3 ro = vec3(0);
  // vec3 rd = normalize(vec3(uv, 1));
  float t = T * 4.;
  vec3 ro = path(t);
  vec3 front = normalize(path(t+2.) - ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  vec3 rd = mat3(right, up, front) * normalize(vec3(uv, 1));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    float d = length(p.xy-path(p.z).xy)-3.;
    d = d * (1.-hash12(uv.xy*100.+T)*.2);  // 使用噪点消除伪影

    d = abs(d)+.01;
    d += fbm(p*2.);

    float glow = sin(p.z)*.5+.5;

    col += glow * (1.1+sin(vec3(3,2,1)+p.x+p.z))/d;
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e2);
  O.rgb = col;
}