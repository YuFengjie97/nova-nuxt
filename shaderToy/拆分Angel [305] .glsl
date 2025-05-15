// https://www.shadertoy.com/view/Wf3GzS
#define PI 3.141596

vec3 noise33(vec3 p){
  return sin(p.yzx);
}

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://easings.net/#easeOutElastic
float easeOutElastic(float x) {
  return clamp(0.,1.,pow(2., -10. * x) * sin((x * 10. - 0.75) * PI*0.3) +0.7);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float T = iTime;

  vec2 m = (iMouse.xy*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  // todo 测试ro z为0
  vec3 ro = vec3(0.,0.,0.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float d = 0.;

  for(float i=0.;i<50.;i++){
    vec3 p = rd * z + ro;

    p.z += -16.;
    p.xz *= rotate(iTime * 0.2);

    if(iMouse.z > 0.) {
      p.xz *= rotate(m.x * PI * 2.);
      p.yz *= rotate(m.y * PI * 2.);
    }

    float freq = .5;
    // amp 累积过大,会让颜色(形状)出现过多的噪音
    float amp = 1.;
    for(float i=1.;i<15.;i++){
      p += amp * sin(p.zxy * freq + T * 0.1) / freq;
      // freq *= 1.3 + easeOutElastic(fract(T*0.6)) * 0.8;
      freq *= 1.5 + .8 * (sin(T) * 0.5 + 0.5);
      amp *= 1.;
    }

    // xyz是圆
    // xy,xz,yz,是线
    // x,y,z是面
    d = .01 + abs(length(p.xyz) - 5.) / 10.;
    O.rgb = (sin(z + vec3(3, 2, 1)) + 1.1) / d;
    O.rgb = tanh(O.rgb * 0.04);

    z += d;

    // if(z > 1e3 || d < 1e-3) break;
  }
}