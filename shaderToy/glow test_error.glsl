// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

/**
reflect and union obj: https://www.shadertoy.com/view/W3cXDl
Separation AA function: https://www.shadertoy.com/view/tcjXDW
*/

#define T iTime
#define PI 3.141596
#define S smoothstep
#define R iResolution.xy

const float EPSILON = 1e-6;

float glow = 0.;
float getGlow(float d,float r, float ins){
  return pow(r/max(d, 1e-6),ins);
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

struct Obj {
  float d;
  float id;
};

Obj ObjUnion(Obj o1, Obj o2){
  if(o1.d < o2.d){
    return o1;
  }
  else{
    return o2;
  }
}

vec3 cross_pos = vec3(0,.1,-1);
// repeat box
Obj obj_1_1(vec3 p){
  p -= cross_pos;
  float d = sdCapsule(p, vec3(-1,-1,0), vec3(1,1,0), .1);
  return Obj(d, 0.);
}

Obj obj_1_2(vec3 p){
  p -= cross_pos;
  float d1 = sdCapsule(p, vec3(1,-1,0), vec3(.2,-.2,0), .1);
  float d2 = sdCapsule(p, vec3(-1,1,0), vec3(-.2,.2,0), .1);
  float d = min(d1,d2);
  
  glow += getGlow(d, .01, 1.6);
  return Obj(d, 1.);
}

Obj obj_2(vec3 p){
  float d = p.y + 1.;
  d = abs(d);
  return Obj(d, 2.);
}

vec3 objCol(vec3 p, Obj obj){
  vec3 col = vec3(0);
  if(obj.id == 0.){
    col = sin(vec3(3,2,1)+(p.x+p.z)*4.)+1.;
  }
  else if(obj.id == 2.){
    col = vec3(0.);
  }
  return col;
}

Obj map(vec3 p) {
  Obj o1_1 = obj_1_1(p);
  Obj o1_2 = obj_1_2(p);
  Obj o2 = obj_2(p);
  // return o1_2;

  return ObjUnion(o2, ObjUnion(o1_1, o1_2));
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

// https://www.shadertoy.com/view/lsKcDD
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = map( pos + h*nor ).d;
        occ += (h-d)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 1.5*occ, 0.0, 1.0 );    
}

// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ).d + 
					  e.yyx*map( pos + e.yyx*eps ).d + 
					  e.yxy*map( pos + e.yxy*eps ).d + 
					  e.xxx*map( pos + e.xxx*eps ).d );
}

struct RM{
  float z;
  bool hit;
};


RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    Obj obj = map(p);
    float d = obj.d;
    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }

  return RM(z, hit);
}

vec3 reflectCol(vec3 ro, vec3 rd){
  float zMax = 30.;
  float z = .1;
  vec3 p;
  Obj obj;
  for(float i=0.;i<256.;i++){
    p = ro + rd * z;
    obj = map(p);
    float d = obj.d;
    z+=d;
    if(d<EPSILON || z > zMax) break;
  }
  vec3 col = objCol(p, obj);
  return col;
}

// https://iquilezles.org/articles/rmshadows/
float softshadow( in vec3 ro, in vec3 rd )
{
    float w = .5;
    float mint = .01;
    float maxt = 20.;
    float res = 1.0;
    float ph = 1e20;
    float t = mint;
    for( int i=0; i<256 && t<maxt; i++ )
    {
        float h = map(ro + rd*t).d;
        if( h<0.001 )
            return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, d/(w*max(0.0,t-y)) );
        ph = h;
        t += h;
    }
    return res;
}

float hash(float v){
  return fract(sin(v*.5 + cos(v*2.))*21.23);
}

vec3 render(vec2 uv){

  vec3 ro = vec3(0,-.4,3.);
  // float mx = iMouse.x/R.x*6.;
  // if(iMouse.z>0.){
    // ro.xz = vec2(cos(mx),sin(mx))*3.;
  // }
  float mx = T;
  ro.xz = vec2(cos(mx),sin(mx))*3.;


  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  vec3 col = vec3(0);
  vec3 p = ro + rd * z;
  vec3 nor = calcNormal(p);
  Obj obj = map(p);
  col = objCol(p, obj);

  vec3 l_pos = vec3(5,5,5);
  vec3 l_dir = normalize(l_pos-p);


  if(obj.id == 0.) {
    float diff = max(0., dot(normalize(vec3(0,10,4)), nor));
    col = col * diff;
    // float spe = pow(diff, 30.);
    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 50.);
    col += spe;
  }

  // plane reflect
  if(obj.id == 2.){
    // reflect col
    vec3 rd = normalize(reflect(normalize(p-ro), nor));
    vec3 ref_col = reflectCol(p, rd);
    col = mix(col, ref_col, .2) * exp(-2.*z*z*z);
  }

  // shadow
  // float shadow = softshadow(p, l_dir);
  // col *= shadow;

  col *= calcAO(p, nor);

  // col *= exp(-1e-5*z*z*z);

  float flash = step(.1, hash(T));
  col += flash * glow * (sin(vec3(3,2,1)+T)*.5+.5);

  col = pow(col, vec3(.4545));

  return col;
}


void mainImage(out vec4 O, in vec2 I){
  // vec2 R = iResolution.xy;
  O.rgb *= 0.;
  O.a = 1.;
  vec2 uv = (I*2.-R)/R.y;

  int AA = 2;
  vec3 tot = vec3(0);
  for(int m=0;m<AA;m++){
  for(int n=0;n<AA;n++){
    vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5;
    vec2 uv = (2.0*(I+o)-R)/R.y;
    vec3 col = render(uv);
    tot += col;
  }}

  tot /= float(AA*AA);

  O.rgb = tot;
}