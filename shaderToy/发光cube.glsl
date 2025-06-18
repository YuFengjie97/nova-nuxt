#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O *= 0.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));
  float z;
  float d;
  vec3 col = vec3(0);

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= rotate(iTime * .2);
    p.xy *= rotate(iTime * .1);

    // cube https://www.shadertoy.com/view/lcV3Rz
    vec3 p1 = abs(p);
    float d = max(p1.x,max(p1.y,p1.z))-3.;
    d = abs(d)+0.1;     // transparent
    
    
    
    float ins = sin(T*6.)*0.5+0.5;

    // color and glow
    //col += (1.+sin(vec3(3,2,1)+p.x*2.))/d;
    col += (1.+sin(vec3(3,2,1)+p.x*0.5+T*6.))/d*(0.1+0.9*ins);   // *scale  change light intensity
    //col += vec3(1,0,0)/d;

    z += d*.7;    // *scale make blur
    if(z>1e2 || d<1e-3) break;
  }

  O.rgb = tanh(col*5e-2);
}