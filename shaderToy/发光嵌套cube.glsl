#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://iquilezles.org/articles/distfunctions/
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

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    
    for(float i=1.;i<5.;i++){
      vec3 q = p;
      q.xz *= rotate(iTime * .2*i + i);
      q.xy *= rotate(iTime * .2*i + i);

      float D = sdBox(q, vec3(i));

      // if(D<.4){
        col += (1.+sin(vec3(3,2,1)+q.x+i))/D*(1.-i*0.2)*0.01;
      // }

      d = min(d, D);
    }


    z += d*0.6;
    if(z>1e2 || d<1e-4) break;
  }

  O.rgb = tanh(col*3e-1);
}