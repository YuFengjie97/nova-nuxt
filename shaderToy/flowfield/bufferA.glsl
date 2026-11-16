#iChannel0 "./bufferA.glsl"
#iChannel1 "../pic/buttfly.png"
#iChannel2 "../pic/rock.png"

const float G = 20.;

float F(vec2 p){
  return texture(iChannel2, p).r;
}


vec2 flowField(vec2 p){
  float e = .1;
  float dx = F(p+vec2(e,0.))
           - F(p-vec2(e,0.));
  float dy = F(p+vec2(0.,e))
           - F(p-vec2(0.,e));
  return normalize(vec2(-dx, dy));
}


void check(inout vec4 O, vec2 I, vec2 nei){
  // 邻居像素保存的 当前邻居距离最近粒子的位置
  vec2 n = texture(iChannel0, (I + nei)/iResolution.xy).xy;                        
  if (length(n - I) < length(O.xy - I))
    O.xy = n; 
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  O = texelFetch(iChannel0, ivec2(I), 0);
  vec2 uv = (I)/R.y;

  O.xy += flowField(O.xy/R)*.4;

  for(float i=1.;i<4.;i++){
    check(O, I, i*vec2(1,0));
    check(O, I, i*vec2(-1,0));
    check(O, I, i*vec2(0,1));
    check(O, I, i*vec2(0,-1));
  }


  O.z -= 0.05 * O.z;
  O.z += .05/length(O.xy-I);

  if(iFrame<10){
    O.xy = (floor(I/G)+.5)*G;
    O.z = 0.;
  }
}