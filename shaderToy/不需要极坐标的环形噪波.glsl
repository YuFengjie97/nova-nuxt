#iChannel0 "./pic/rock.png"
#iChannel1 "./pic/noise_64.png"
#define T iTime

float noise(vec2 p){
  return texture(iChannel1, p).r;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  float n1 = noise(uv*.02+T*.04)   -.5;
  float n2 = noise(uv*.02-T*.04+.1)-.5;
  vec2 n = vec2(n1, n2);

  float d = abs(length(uv + n*.1)-.5);


  // d = smoothstep(.03,0.,d);
  d = pow(.01/d, 2.);

  O.rgb += d;
}