#iChannel0 "../pic/char.png"
#define T iTime

float charTex(vec2 p, vec2 i){
  float size = 16.;
  vec4 v = texture(iChannel0, (p+i)/size);
  float d = v.a;
  return d;
}

float remap01(float v, float vmin, float vmax){
  return clamp((v-vmin)/(vmax-vmin),0., 1.);
}

vec2 remap01V2(vec2 v, vec2 vmin, vec2 vmax){
  float x = remap01(v.x, vmin.x, vmax.x);
  float y = remap01(v.y, vmin.y, vmax.y);
  return vec2(x,y);
}

vec3 glowChar(vec2 p, vec2 i, float seed){
  float d = charTex(p, i);

  float e = .6;
  float dx = charTex(p+vec2(e,0), vec2(1))-d;
  float dy = charTex(p+vec2(0,e), vec2(1))-d;
  vec2 tang = vec2(dy, -dx);
  float a = atan(tang.y, tang.x);
  vec3 col = sin(vec3(3,2,1)+a+T*5.+seed)*.5+.5;

  float edgeWidth = .1;
  float mask = smoothstep(0.,edgeWidth, d-.5) * smoothstep(edgeWidth,0.,d-0.5);
  // return mask * col;
  mask += pow(.002/max(0.01, d-.5), 2.);
  return mask * col;
}

float hash(float p) {
    // p = fract(p * 0.1031);
    // p *= p + 33.33;
    // p *= p + p;
    // return fract(p);
  return abs(sin(p));
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I)/R.y;
  O.rgb *= 0.;
  float pix = 1./R.y;

  
  const int count = 18;
  vec2 char1[count];
  char1[0] = vec2(4 , 10); //T
  char1[1] = vec2(8 , 9);  //h
  char1[2] = vec2(9 , 9);  //i
  char1[3] = vec2(14 , 9); //n
  char1[4] = vec2(11 , 9); //k
  char1[5] = vec2(0 , 5);  // 
  char1[6] = vec2(6 , 9);  //f
  char1[7] = vec2(13 , 14); //o
  char1[8] = vec2(2 , 8);  //r
  char1[9] = vec2(0 , 5);  // 
  char1[10] = vec2(9 , 8); //y
  char1[11] = vec2(15 , 9); //o
  char1[12] = vec2(5 , 8); //u
  char1[13] = vec2(2 , 8); //r
  char1[14] = vec2(3 , 8); //s
  char1[15] = vec2(5 , 9); //e
  char1[16] = vec2(12 , 9); //l
  char1[17] = vec2(6 , 9); //f

  vec2 char2[count];
  char2[0] = vec2(4 , 10); //T
  char2[1] = vec2(8 , 9);  //h
  char2[2] = vec2(9 , 9);  //i
  char2[3] = vec2(14 , 9); //n
  char2[4] = vec2(11 , 9); //k
  char2[5] = vec2(0 , 5);  // 
  char2[6] = vec2(7 , 8);  //w
  char2[7] = vec2(9 , 9); //i
  char2[8] = vec2(4 , 8);  //t
  char2[9] = vec2(8 , 9);  //h 
  char2[10] = vec2(0 , 5); //
  char2[11] = vec2(1 , 11); //A
  char2[12] = vec2(9 , 11); //I
  char2[13] = vec2(0 , 5); //
  char2[14] = vec2(0 , 5); //
  char2[15] = vec2(0 , 5); //
  char2[16] = vec2(0 , 5); //
  char2[17] = vec2(0 , 5); //
  
  float size = .12;
  vec2 start = vec2(0.1,.5);
  float x = start.x;
  float subGap = .04;
  for(int i=0; i<count; i++){
    x += size - subGap;
    vec2 p = remap01V2(uv,  vec2(x, start.y), 
                            vec2(x+size, start.y+size)
                      );

    float h = hash(float(i)*.1-T*2.1);
    vec2 char = h > 0.5 ? char1[i] : char2[i];
    O.rgb += glowChar(p, char, float(i)*.2)*10.;
  }

  float d = smoothstep(1.*pix, 0., abs(uv.y-.5)-1.*pix);
  O.rgb += d;
}