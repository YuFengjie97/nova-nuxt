#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"


#define PI 3.141596
#define petalLen 0.6
#define petalNum 5.
#define rotateSpeed .5
#define rotateAmp 0.2
#define baseScale 6.
#define baseRadius .4

float noise(vec2 p) {
  return texture(iChannel0, p).r - 0.2;
}

float fbm(vec2 p){
  float freq = 2.;
  float amp = 0.5;
  float val = 0.;
  for(float i=0.;i<8.;i++){
    val += amp * noise(p * freq);
    amp *= .5;
    freq *= 2.;
  }
  return val;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*.5)/R.y;
  vec3 col = vec3(0.);


  uv = vec2(atan(uv.y, uv.x)/PI*0.5, log(length(uv)*baseScale + baseRadius));
  uv.x += sin((uv.y) - iTime * rotateSpeed) * rotateAmp;


  float x = uv.x * petalNum;
  float v = uv.y - abs(fract(x)-0.5);
  float n = fbm(uv+iTime*0.01);
  v += n;
  float shape = smoothstep(0.7,0.,v);
  vec3 c = sin(vec3(3.,2.,1.) * PI *v + iTime)*0.5 + 0.5;
  col += shape * c;


  O = vec4(col, 1.);
}