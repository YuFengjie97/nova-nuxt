#define white vec3(1.)
#define black vec3(0.)
#define red vec3(1.,0.,0.)
#define PI 3.141596


vec3 hierophant(vec2 p){
  p -= 0.5;
  p = abs(p);
  // 中心十字
  float d = min(abs(p.x), abs(p.y));
  float s = smoothstep(fwidth(d)+0.1,0.1,d) * step(p.y, 0.33) * step(p.x, 0.33);
  // 边框
  float w2 = 0.5;
  float d2 = min(abs(p.x-w2), abs(p.y-w2));
  float s2 = smoothstep(fwidth(d2)+0.02,0.02,d2);
  s = max(s, s2);
  // 边框2
  float w3 = 0.4;
  float bw3 = 0.02;
  float d3 = min(abs(p.x-w3), abs(p.y-w3));
  float s3 = smoothstep(fwidth(d3)+bw3,bw3,d3) * step(p.y,w3+bw3) * step(p.x,w3+bw3);
  s = max(s, s3);

  for(float i=0.;i<4.;i++){
    vec2 q = p - 0.25;
    float w = 0.03 * i;
    float bw = 0.01;
    float dl = min(abs(q.x - w), abs(q.y - w));
    float sl = smoothstep(fwidth(dl)+bw,bw,dl);
    s = max(s, sl);
  }


  return white * s;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*0.5)/R.y;
  vec3 col = vec3(0.);
  uv *= vec2(2.);
  vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);
  float i = uvi.y * 5.+uvi.x;
  if(uvi.x==0. && uvi.y==0.){
    col = hierophant(uvf);
  }
  if(uvi.x==0. && uvi.y==-1.){
  }
  if(uvi.x==-1. && uvi.y==0.){
  }
  if(uvi.x==-1. && uvi.y==-1.){
  }

  O = vec4(col, 1.);
}