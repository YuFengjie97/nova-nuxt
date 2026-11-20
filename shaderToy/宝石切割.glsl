#define PI 3.1415926
#define T iTime

vec3 C = vec3(3,2,1);

mat2 rot(float a){
  float c = cos(a);
  float s=  sin(a);
  return mat2(c,s,-s,c);
}

vec3 hash31(float p){
  vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx+33.33);
  return fract((p3.xxy+p3.yzz)*p3.zyx); 
}

vec3 H31 = vec3(3.,1.2,2.);

float clipping(float d, vec3 p, float seed){
  vec3 q = p;
  vec3 h = hash31(seed);
  H31 = h;
  q.yz *= rot(h.x*10.);
  q.xz *= rot(h.y*10.);
  q.xy *= rot(h.z*10.);

  // C += h;

  float planeY = -abs(q.y)+2.5+h.x*.5;
  float planeX = -abs(q.x)+2.5+h.y*.5;
  float plane = min(planeX, planeY);
  // float plane = q.y-.4;
  return max(d, -plane);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return max(q.x,max(q.y, q.z));
  // return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p){
  // float d = length(p)-4.;
  float d = sdBox(p, vec3(4));

  for(float i=0.;i<4.;i++){
    d = clipping(d, p, i*213.41+floor(T*.6));
  }

  return d;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;

  vec3 p;
  vec3 ro = vec3(0,0,-10);
  vec3 rd = normalize(vec3(uv,1));

  float i = 0.;
  float z = 0.;
  
  while(i<50.){
    p = ro + rd * z;

    p.xy *= rot(T);
    p.yz *= rot(T);

    float d = map(p);
    d = abs(d)*.5 + .01;
    z += d;

    vec3 col = sin(C+H31*44.32)*.5+.5;
    float l = dot(col, vec3(0.299, 0.587, 0.114));

    O.rgb += 1. / d * col / l;
    i++;

    if(d<.01)break;
  }

  O.rgb = tanh(O.rgb * 4e-4);
  // O.rgb = 1.-exp(-O.rgb*.01);
}