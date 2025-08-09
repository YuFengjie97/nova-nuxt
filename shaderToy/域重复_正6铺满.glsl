// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283192
#define S smoothstep
const float EPSILON = 1e-6;



mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

struct Obj{
  float d;
  float id;
};

Obj obj_union(Obj o1, Obj o2){
  if(o1.d < o2.d)return o1;
  return o2;
}


float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}
float sdHexagonCard(vec3 p, float r){
  return length(vec2(max(sdHexagon(p.xy, r), 0.), p.z))-.04;;
}
float sdHexPrism( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float glow = 0.;
vec3 l_pos = vec3(0);
Obj map(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    p.xz*=rotate(m.x);
    p.yz*=rotate(m.y);
  }
  p.xy *= rotate(mod(p.z*.08, TAU));
  // p.xy *= rotate(p.z*.08);

  p.y = 10.-abs(p.y);
  // p.y = 10.+p.y;

  float d = p.y;
  Obj o1 = Obj(d, 0.);

  vec3 q = p;
  float s = 2.;
  vec2 id = round(q.xz/s);
  // id.x = clamp(id.x, -4., 4.);
  q.xz -= id*s;
  float d1 = sdHexagonCard(q.xzy, .82)-.1;
  // float d1 = sdHexPrism(q.xzy, vec2(.8, .2));
  Obj o2 = Obj(d1, id.x+id.y);

  float d_glow = length(p - l_pos)-.1;
  d_glow = max(0., d_glow);
  glow += pow(.3/d_glow, 1.4);
  Obj o3 = Obj(d_glow, -1.);

  o1 = obj_union(o1, o2);
  o1 = obj_union(o1, o3);
  return o1;
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
vec3 calcNormal2( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.01;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ).d + 
					  e.yyx*map( pos + e.yyx*eps ).d + 
					  e.yxy*map( pos + e.yxy*eps ).d + 
					  e.xxx*map( pos + e.xxx*eps ).d );
}
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,0.);
    const float eps = 0.01;
    e *= eps;
    return normalize(vec3(
            map( pos + e.xyy).d - map(pos - e.xyy).d,
					  map( pos + e.yyx).d - map(pos - e.yyx).d,
					  map( pos + e.yxy).d - map(pos - e.yxy).d
    ));
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
    float d = map(p).d;

    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d*.6;
  }

  return RM(z, hit);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.);
  ro.z += T;
  l_pos = ro + vec3(0,0,40.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  vec3 rd = normalize(vec3(uv, 1.));
  // vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  vec3 col = vec3(0);
  vec3 p = ro + rd * z;

  vec3 nor = calcNormal(p);
  // vec3 objCol = boxmap(iChannel0, p*.1, nor, 7.).rgb;
  
  Obj obj = map(p);
  if(obj.id == 0.){
    col = vec3(.03);
  }
  if(obj.id > 0.){
    col = sin(vec3(3,2,1)+obj.id)*.5+.5;
  }

  vec3 l_dir = normalize(l_pos-p);
  float diff = max(0., dot(l_dir, nor));
  // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
  float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 60.);

  col *= diff*.3 + spe*20.;

  // col += glow * vec3(1);
  col *= calcAO(p, nor);

  col *= S(1.,0.,z/zMax);
  col = pow(col, vec3(.4545));
  
  O.rgb = col;

}