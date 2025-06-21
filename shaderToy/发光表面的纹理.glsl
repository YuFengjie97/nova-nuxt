#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.jpg"


#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://iquilezles.org/articles/distfunctions/
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  float d = min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
  return abs(d)+0.1;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  float d = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
  // return d;
  return abs(d)+0.1;
}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float f = 1.;
  float a = 1.;
  float n = 0.;
  for(float i=0.;i<8.;i++){
    n += noise(p*f)/f;
    f *= 2.;
    a *= .5;
  }
  return n;
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
  vec3 p;
  vec4 U=vec4(0);

  float t = sin(T);
  for(float i =0.;i<100.;i++){
    p = ro + rd * z;

    // p = mod(p,5.)-0.5;
    p.xz *= rotate(T*0.5);
    p.xy *= rotate(T*0.5);


    d = sdBox(p, vec3(3.));

    U = (1.+sin(vec4(3,2,1,1)  +  dot(p,p)*0.3-T ));
    if(d<.3&&z<10.){
      U += noise((p.xz+p.xy)*.2)*2.;
    }
    O += U.w*U/d;

    z += d*0.1;
    if(z>1e3 || d<1e-4) break;
  }
  O = tanh(O*1e-3);
}