// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// Perlin Noise 2D
vec2 fade(vec2 t) { return t*t*t*(t*(t*6.0-15.0)+10.0); }

float grad(vec2 p, vec2 ip) {
    vec2 g = vec2( fract(sin(dot(ip,vec2(127.1,311.7)))*43758.5453),
                   fract(sin(dot(ip,vec2(269.5,183.3)))*43758.5453));
    g = g*2.0-1.0; // 随机梯度向量
    return dot(p, g);
}

float perlin(vec2 p){
    vec2 ip = floor(p);
    vec2 fp = fract(p);

    float d00 = grad(fp-vec2(0,0), ip+vec2(0,0));
    float d10 = grad(fp-vec2(1,0), ip+vec2(1,0));
    float d01 = grad(fp-vec2(0,1), ip+vec2(0,1));
    float d11 = grad(fp-vec2(1,1), ip+vec2(1,1));

    vec2 u = fade(fp);
    return mix(mix(d00,d10,u.x), mix(d01,d11,u.x), u.y);
}

// Generic Gradient Noise-------------------------------
float hash(vec2 p){
    return fract(sin(dot(p, vec2(127.1,311.7)))*43758.5453);
}

vec2 randomGradient(vec2 p){
    float a = hash(p) * 6.2831853; // 随机角度
    return vec2(cos(a), sin(a));
}

float gradientNoise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);

    // 四个角
    vec2 g00 = randomGradient(i+vec2(0,0));
    vec2 g10 = randomGradient(i+vec2(1,0));
    vec2 g01 = randomGradient(i+vec2(0,1));
    vec2 g11 = randomGradient(i+vec2(1,1));

    float v00 = dot(g00, f-vec2(0,0));
    float v10 = dot(g10, f-vec2(1,0));
    float v01 = dot(g01, f-vec2(0,1));
    float v11 = dot(g11, f-vec2(1,1));

    vec2 u = f*f*(3.0-2.0*f); // 另一种平滑函数
    return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  uv *= 10.;

  float n1 = gradientNoise(uv);
  float n2 = perlin(uv);

  float n = uv.x < 0. ? n1 : n2;
  O.rgb += n*2.;

  float l = S(51./R.y, 50./R.y, abs(uv.x));
  O.rgb = mix(O.rgb, vec3(1,0,0), l);
}