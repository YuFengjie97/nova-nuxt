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
  // return d;
  return abs(d)+0.1;
}

float sdCube(vec2 p, float r){
  vec2 q = abs(p);
  float d = max(q.x,q.y)-r;
  return d;
}


float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O *= 0.;
  O.a = 1.;

  vec3 col = vec3(0);

  uv *= 20.;

  // float dist = length(uv);
  // float i = mod(dist, 4.);
  // float d = abs(i-0.5);
  // d = S(0.4,0.,d);
  // O.rgb += d;

  // {
  //   vec2 p = abs(uv)-vec2(0.5);
  //   float dist = length(max(p,0.0)) + min(max(p.x,p.y),0.0);
  //   float i = mod(dist, 4.);
  //   float d = abs(i-0.5);
  //   d = S(0.4,0.,d);
  //   O.rgb += d;
  // }

  // {
  //   vec2 p = abs(uv);
  //   float dist = max(p.x,p.y);
  //   float i = mod(dist, 4.);
  //   float d = abs(i-0.5);
  //   d = S(0.4,0.,d);
  //   O.rgb += d;
  // }
  {
    // float d = sdCube(uv, .0);
    float d = sdBox(uv, vec2(105.));
    d = mod(d, 4.);
    d = abs(d-0.5);
    d = S(.1,0.,d);
    O.rgb += d;
  }
}