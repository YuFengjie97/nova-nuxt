#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireSkull/bufferB.glsl"

#define T iTime

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// --- Simplex Noise 主体 ---
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

mat2 rot2D(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

float fbm(vec2 p){
  float a = .5;
  float n = 0.;
  // mat2 rot = rot2D(1.5);
  // mat2 rot = mat2( 1.6,  1.2, -1.2,  1.6 );

  for(float i=0.;i<4.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}

vec2 twist(vec2 p, vec2 scale, vec2 offset){
  p *= scale;
  p += offset;
  return p;
}


float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  I += noise(I/R * 10.+T) * 3.; // 形状扭曲噪音

  vec4 D = texelFetch(iChannel1, ivec2(I), 0);   // 必须使用texelFetch,用归一化的uv坐标来展示jfa计算后的图像,会导致撕裂,挤压,不连续
  float d = (length(I-D.xy) - length(I-D.zw)) / R.y;
  d = 1.-pow(d * 8., .3);  // d*缩减范围,pow自性增强,1-反转形状

  vec2 scale = vec2(15., 5.);
  vec2 offset = vec2(0., -2.)*mod(T*0.6, 60.);
  float n = fbm(uv*scale + offset);
  d *= 1.+n;    // *1保持自己的形状 *n范围加入噪音特征

  float v = .5;
  float feath = fract(v)*0.2;
  d = smoothstep(v-feath,v,d);

  O.rgb += d * vec3(1.,0.,0.);
}