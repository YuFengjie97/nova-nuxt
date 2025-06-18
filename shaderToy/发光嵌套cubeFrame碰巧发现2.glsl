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



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O *= 0.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));
  float z;
  float d=1e4;
  vec3 col = vec3(0);

  vec4 A = vec4(0,33,11,0);
  float t = sin(T);

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    // some twist rotate always be fun
    vec3 q=p;
    mat2 R1 = rotate(iTime * .1 * floor(i/5.));
    mat2 R2 = rotate(iTime * .1 + floor(i/4.));
    q.xy *= R1;
    q.xz *= R2;
    q.yz *= R1;


    // float D = sdBoxFrame(q, vec3(4.), 0.);
    float D = sdBox(q, vec3(4.));

    col += (1.1+sin(vec3(3,2,1)+(q.x+q.y)*0.3))/D;

    d = min(d, D);

    z += d;
    if(z>1e2 || d<1e-4) break;
  }

  O.rgb = tanh(col*5e-3);
}