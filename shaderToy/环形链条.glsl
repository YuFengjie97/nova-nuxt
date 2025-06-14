#define PI 3.141596
#define T iTime

mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

// iq: https://www.shadertoy.com/view/wlXSD7
float sdLink( in vec3 p, in float le, in float r1, in float r2 )
{
    vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
    return length(vec2(length(q.xy)-r1,q.z)) - r2;
}

float map(vec3 p){
  float le = 0.1;
  float r1 = 0.1;
  float r2 = 0.1;
  float d = sdLink(p, le, r1, r2);
  return d;
}
float getNormal(vec3 p, vec3 light){
  light = normalize(light-p);
  vec2 e = vec2(0.01,0);
  vec3 g = normalize(vec3(
    map(p+e.xyy)-map(p-e.xyy),
    map(p+e.yxy)-map(p-e.yxy),
    map(p+e.yyx)-map(p-e.yyx)
  ));
  float dif = dot(light, g);
  return dif;
}




void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;

  O.rgb *= 0.;
  O.a = 1.;
  vec3 ro = vec3(0,0,-1);
  vec3 rd = normalize(vec3(uv, 1.));
  float d = 0.;
  float z = 0.;
  float zMax = 5.;
  vec3 p;

  

  for(float i=1.;i<100.;i++){
    p = ro + rd * z;
    if(iMouse.z > 0.){
      p.xz *= rotate(m.x*2.);
      p.yz *= rotate(m.y*2.);
    }
    d = map(p);
    z += d;
    if(d<1e-4 || z>zMax)break;
  }

  if(z < zMax) {
    float dif = getNormal(p, vec3(1,1,-1));
    O.rgb = dif * vec3(3,2,1);
  }
}