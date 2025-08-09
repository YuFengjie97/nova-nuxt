// base is from https://www.shadertoy.com/view/XsfGzH

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/hash_rgb_256.png"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// xy分布对应两个通道的hash值
vec2 hash22(vec2 p){
  return texture(iChannel0, p/256.).xy; // 归一化 --> 3D下的p坐标 / 256为图片的像素(值)尺寸
}

float hash21(vec2 uv){
  return texture(iChannel0, uv).r;
}

/*
2D噪音构建3D噪音的方法:
p.xy对应hash纹理的坐标,以z轴铺满无限层
以p.z让纹理取样的坐标做出偏移
这样导致前后两层的噪音值在同p.xy处,值的差别很大
用平滑后的f.z来使这两层进行混合
这样就得到了在z轴方向,连续的噪音
*/
float noise(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);

  f = f*f*(3.-2.*f);
  // f = S(0.,1.,f);
  vec2 uv = i.xy + i.z * vec2(37., 17.) + f.xy;
  vec2 xy = hash22(uv).yx;
  return mix(xy.x, xy.y, f.z);
}

mat3 m = mat3( 0.30,  0.90,  0.60,
              -0.90,  0.36, -0.48,
              -0.60, -0.48,  0.34 );

float fbm(vec3 p){
  float f;
  f  = 1.6000*noise( p ); p = m*p*2.02;
  f += 0.3500*noise( p ); p = m*p*2.33;
  f += 0.2250*noise( p ); p = m*p*2.03;
  f += 0.0825*noise( p ); p = m*p*2.01;
  return f;
  // float amp = 2.;
  // float fre = 1.;
  // float res = 0.;
  // for(float i=0.;i<5.;i++){
  //   res += amp*noise(p*fre);
  //   amp *= .5;
  //   fre *= 2.;
  // }
  // return res;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy-R)/R * PI*2.;

  O *= 0.;

  vec3 ro = vec3(0.,0.,-1.);
  vec3 rd = normalize(vec3(uv, 1.));


  float zMax = 50.;
  float z = hash21(uv.xy*3132.);
  float d = 0.;
  vec4 col = vec4(0,0,0,1);
  vec3 p;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    p.xz *= rotate(T*.3);
    // p.z -= T*.5;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    col.a *= .08;

    // d = -abs(p.y)+2.;
    d = p.y-2.;
    d += fbm(p)*4.;
    d = clamp(d, 0., 1.);

    if(d<EPSILON || z>zMax) break;
    z += max(0.1,z*.02);
  }
  vec3 cloud_col = (.2+.2*sin(vec3(3,2,1)+(p.z)));
  // vec3 bg = mix(vec3(1,0,0), vec3(0), uv.y);
  vec3 bg = vec3(0);
  col.rgb = mix(bg, cloud_col, 1.-d);
  O = col;
}