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
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  float d = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
  // return d;
  return abs(d)+0.1;
}


float sdCube(vec3 p, float r){
  vec3 q = abs(p);
  float d = max(q.x,max(q.y,q.z))-r;
  return d;
  // return abs(d)+0.1;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O *= 0.;

  vec3 ro = vec3(0.,0.,-30.);
  vec3 rd = normalize(vec3(uv, 1.));
  float z;
  vec3 col = vec3(0);

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    
    vec3 q = p;
    q.xy *= rotate(T*0.5);
    q.yz *= rotate(T*0.5);
    q.xz *= rotate(T*0.5);

    float d = sdBoxFrame(q, vec3(1.2)*i, 0.)*0.5;
    // float d = sdBox(q, vec3(1.2)*i);

    col += (1.1+sin(vec3(3,2,1)+(p.x+p.y+p.z)*.02+T))/d;

    z += d*0.6;
    if(z>1e5 || d<1e-4) break;
  }
  O.a = 1.;
  O.rgb = tanh(col*5e-2);
}