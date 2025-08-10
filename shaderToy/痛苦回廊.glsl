//https://www.shadertoy.com/view/WXGXR3

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
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


float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 path(float z){
  return vec3(cos(z)*2., 0, z);
}


// https://www.shadertoy.com/view/4djSRW
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy+p3.yzz)*p3.zyx);
}

vec3 getTurbulence(vec3 p, float n){
  float amp = 2.;
  float fre = 1.;
  for(float i =0.;i<n;i++){
    p += amp*sin(p.zxy*fre+p.x*.1);
    amp*=.5;
    fre*=2.;
  }

  return sin(vec3(3,2,1)+(p.x+p.y+p.z));
}


Obj map(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    // p.xz*=rotate(m.x);
    // p.yz*=rotate(m.y);
  }
  float d = p.y;
  // float d = 1e3;
  Obj o = Obj(d, 0.);

  {
    vec3 q = p;
    q.x = -abs(q.x);
    float s = 3.;
    float id = round(p.z/s);
    q.z -= id*s;
    float d1 = .6 * sdBox(q-vec3(-6.-sin(id*2.+T*2.)*1.,0.,0), vec3(2., 100., .2));
    o = obj_union(o, Obj(d1, id));
  }
  return o;
}

mat3 setCamera( in vec3 ro, in vec3 ta )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(0.,1.,0.);  // 滚角
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

float rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).d;
    if(z>zMax || d<EPSILON) break;
    z += d;
  }
  return z;
}

struct Mat{
  float dif;
  float spe;
  float fre;
};

vec3 getLight(vec3 l_dir, vec3 l_col, vec3 nor, vec3 rd, Mat mat){
  float diff = max(0., dot(l_dir, nor));
  float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
  float fre = pow(max(1.-dot(nor, -rd),0.),3.);

  return l_col * (diff*mat.dif + spe*mat.spe + fre*mat.fre);
}

vec3 getObjCol(Obj obj, vec3 p){
  // 柱子
  if(obj.id!=0.){
    // return sin(vec3(3,2,1)+p.z)*.5+.5;
    return getTurbulence(p*.5+vec3(0,-T,T), 4.);
  }

  // 地板
  // return vec3(0);
  return getTurbulence(p*.1+T*vec3(0,.4,0.), 4.)*.5+.5;
}

vec3 reflectCol(vec3 p, vec3 rd, vec3 nor){
  vec3 rd_ref = reflect(rd, nor);         // 视角-->--平-|nor|-面---->反射方向
  float z = rayMarch(p, rd_ref, .1, 20.); // 反射的raymarch的起点为当前位置p
  p = p + rd_ref * z;                     // 反射后,到达新的p点
  Obj o = map(p);
  vec3 col = getObjCol(o, p); 
  float att = S(4.,0.,z);                 // 根据步进距离衰减
  return col*att;
}
vec3 refractCol(vec3 p, vec3 rd, vec3 nor){
  vec3 rd_ref = refract(rd, nor, 1./1.5);  // 第一次折射,空气进入玻璃
  float z = rayMarch(p, rd_ref, .1, 10.); // 在物体内部raymarch
  p = p + rd_ref * z;                     // 碰撞到物体的另一侧
  
  Obj o = map(p);
  // vec3 col = vec3(0,0,0);
  vec3 col = getObjCol(o, p+vec3(33,21,45)); // 另一侧的颜色可能变化不是很大,这里给他加个很大的偏移           
  // float att = S(2.,0.,z);
  // col *= att;    // 效果并不明显

  // nor = -calcNormal(p);
  // rd_ref = refract(rd_ref, nor, 1.5/1.); // 第二次折射,玻璃进入空气,这里不做了,颜色太多了,不明显
  // z  = rayMarch(p, rd_ref, .1, 20.);
  // p = p + rd_ref * z;
  // Obj o = map(p);
  // vec3 col = getObjCol(o, p); 

  return col;
}

// https://iquilezles.org/articles/rmshadows/
float softShadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float res = 1.0;
  float t = mint;

  for(int i = 0; i < 100; i++) {
      float h = map(ro + rd * t).d;
      res = min(res, 8.0*h/t);
      t += clamp(h, 0.02, 0.10);
      if(h < EPSILON || t > tmax) break;
  }

  return clamp( res, 0.0, 1.0 );
}

vec3 ro = vec3(0);
vec3 ta = vec3(0);

vec3 getColor(Obj obj, vec3 p, vec3 rd, vec3 nor){
  vec3 col = getObjCol(obj, p);

  vec3 l_dir = normalize(ta-p);

  // light
  // vec3 l1= getLight(normalize(vec3(0,14,0)) , vec3(.1,.1,1.), nor, rd, Mat(1.,.1, 1.));
  // vec3 l2 = getLight(normalize(vec3(0,4,0)-p), vec3(1.,1.,1.), nor, rd, Mat(1.,1.1, 1.));
  // col *= l1 + l2;

  // reflect
  vec3 col_ref = reflectCol(p, rd, nor); 
  col += col_ref;

  // refract
  vec3 col_reft = refractCol(p, rd, nor);          
  col = mix(col, col_reft, .5);

  // shadow
  float shadow = softShadow(p, l_dir, .1, 10.);
  col *= shadow;


  return col;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  float t = T;
  ro = vec3(0.,4, T);
  ta = vec3(0.,4, T+1.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, ta)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  float z = rayMarch(ro, rd, 0.1, zMax);

  vec3 col = vec3(0);
  vec3 p = ro + rd * z;

  vec3 nor = calcNormal(p);
  
  Obj obj = map(p);

  col = getColor(obj, p, rd, nor);
  
  col *= calcAO(p, nor);

  col *= exp(-1e-4*z*z*z);
  col = pow(col, vec3(.3545));
  O.rgb = col;

}