#define T iTime
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  O.rgb *= 0.;
  O.a = 1.;

  vec2 p = uv*10.;

  vec2 p1 = p;
  // vec2 p1 = mod(p-2.5, 5.) - 2.5;
  float d = length(p1)-0.1;
  mat2 Rot = rotate(T);

  float t = sin(T) * 0.5 + 0.5;

  float s1 = 1.4;
  float s2 = 0.1;
  float s = mix(s1,s2,t);
  
  for(float i=1.;i<10.;i++){
    p1 = abs(p1*Rot)-s*1.5;     // rotate mirror offset 
    
    
    float ss1 = 0.1;
    float ss2 = 1.4;
    float ss = mix(ss1,ss2,t); 
    s *= ss;
    
    
    float d1 = length(p1)-s/2.;
    d = min(d, d1);
  }
  d = S(0.01,0.,d);
  O.rgb += d;
}