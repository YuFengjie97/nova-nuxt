#define T iTime
#define PI 3.141596


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec4 map(vec3 p){
  vec3 col = vec3(0);
  float d;
  float freq = .5;

  p += 0.5000*sin(p.zxy+T*vec3(3,0,0));   p*=2.;
  p += 0.2500*sin(p.zxy+T*vec3(0,3,0));   p*=.5;
  p += 0.1250*sin(p.zxy+T*vec3(0,0,3));   p*=2.;

  d = -(length(p.xy)-10.);
  col = 1.+sin(vec3(3,2,1)+(p.x+p.y+p.z)*0.1);
  return vec4(col, d);
}


// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal2( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ).w + 
					  e.yyx*map( pos + e.yyx*eps ).w + 
					  e.yxy*map( pos + e.yxy*eps ).w + 
					  e.xxx*map( pos + e.xxx*eps ).w );
}

vec3 calcNormal(vec3 p){
  float eps = 0.01;
  vec2 h = vec2(eps, 0.0);
  return normalize(vec3(
    map(p + h.xyy).w - map(p - h.xyy).w,
    map(p + h.yxy).w - map(p - h.yxy).w,
    map(p + h.yyx).w - map(p - h.yyx).w
  ));
}


vec3 rayMarch(vec3 ro, vec3 rd){
  vec3 p;
  float z;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    float d= map(p).w;
    z += d * 350./p.z;

    if(z>100. || d<1e-2) break;
  }
  return p;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));
  ro.z += T;
  vec3 p = rayMarch(ro, rd);
  vec4 M = map(p);
  vec3 col = M.rgb;
  float d = M.w;


  vec3 light = normalize(vec3(1,1,ro.z)-p);
  vec3 nor = calcNormal(p);
  // float dif = dot(light, nor);
  float dif = clamp(dot(light, nor),0.,1.);
  
  O.rgb += dif*col;
  O.rgb = tanh(O.rgb);
}