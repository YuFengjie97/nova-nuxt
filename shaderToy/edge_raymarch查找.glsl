// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define EPSILON 1e-6
#define EDGESIZE 1e-1

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

struct Surface{
  float d;
  vec3 col;
};

float sdGyroid(vec3 p){
  return dot(sin(p),cos(p.yzx));
}

Surface map(vec3 p) {
  p.xz *= rotate(T*.2);
  p.yz *= rotate(T*.2);

  float d = sdBox(p, vec3(2));
  {
    float d1 = length(p-vec3(2,2,2))-2.;
    d = min(d, d1);
  }
  {
    float d1 = sdCapsule(p,vec3(4),vec3(-4),1.);
    d = min(d, d1);
  }
  {
    float d1 = length(p-vec3(-2))-3.;
    d = max(d, -d1);
  }

  vec3 col = vec3(.5);
  return Surface(d, col);
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );
}

// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 p )
{
    const float eps = 1e-5;
    vec2 e = vec2(1.0,-1.0)*eps;
    float d1 = map( p + e.xyy ).d;
    float d2 = map( p + e.yyx ).d;
    float d3 = map( p + e.yxy ).d;
    float d4 = map( p + e.xxx ).d;
    vec3 g1 = e.xyy*d1;
    vec3 g2 = e.yyx*d2;
    vec3 g3 = e.yxy*d3;
    vec3 g4 = e.xxx*d4;
    return normalize(g1+g2+g3+g4);
}

struct RM{
  float z;
  bool hit;
};

float edge = 0.;
float edge_size = .1;
RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  float d_old = zMax;

  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).d;

    if(d_old < edge_size && d > edge_size) edge = 1.;

    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    
    d_old = d;
    
    z += d;
  }

  return RM(z, hit);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  float mx = iMouse.x / R.x* 10.;

  if(iMouse.z>0.){
    ro.xz = vec2(cos(mx),sin(mx))*10.;
  }

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    vec3 objCol = map(p).col;

    vec3 l_dir = normalize(vec3(3,3,-4)-p);
    float diff = max(0., dot(l_dir, nor));

    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);

    col = objCol * .1 + objCol * diff + spe;

  }


  float t = fract(T/6.);
  if(t<.5){
    col += edge*vec3(1,1,0);
  }else{
    col = edge*vec3(1,1,0);
  }

  // col *= exp(-1e-4*z*z*z);
  col = pow(col, vec3(.4545));
  O.rgb = col;

}