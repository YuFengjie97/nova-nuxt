#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/雷电/bufferA.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep

float noise(vec2 p){
  return texture(iChannel0, p).r;
}


float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    n += a * noise(p*f);
    f *= 2.;
    a *= .5;
  }
  return n;
}


mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}


vec2 noisePos(float seed){
  float x = noise(seed + vec2(vec2(0.5,T)*0.008)     )*2.-1.;
  float y = noise(seed + vec2(vec2(0.5,T)*0.008)+0.02)*2.-1.;
  
  // float t = T*2.;
  // float x = sin(seed + t + cos(2.*t));
  // float y = cos(seed + t + sin(2.*t));

  return vec2(x,y);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 p = uv;
  float n = fbm((p+T*0.01)*0.01)-0.5;
  p += n;


  for(float i=0.;i<8.;i++){
    vec2 pos = noisePos(i*13.23);
    float d = length(p-pos);
    
    float r = 0.1;
    d = S(0.,r,d);
    d = pow(r/d,2.);
    
    O.rgb += d * sin(vec3(3.,2.,1.)+i);
  }
  

  O.rgb += texture(iChannel1, I/R).rgb*0.6;
}