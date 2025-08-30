// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
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


Obj map(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    p.xz*=rotate(m.x);
    p.yz*=rotate(m.y);
  }
  float d1 = sdRoundBox(p-vec3(0,0,4), vec3(2.), .1);
  Obj o1 = Obj(d1, 1.);

  float d2 = length(p-vec3(0,0,-4)) - 2.;
  Obj o2 = Obj(d2, 2.);
  return obj_union(o1, o2);

  // float d3 = p.y+10.;
  // Obj o3 = Obj(d3, 3.);

  // return obj_union(o3, obj_union(o1, o2));
}

vec3 getObjCol(vec3 p, float id){
  if(id==1.) return vec3(1,0,0);
  else if(id==2.) return vec3(0,1,0);
  else if(id==3.) return vec3(0,0,0);
  return vec3(0);
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

vec3 calcNormal2(vec3 pos){
  vec2 e = vec2(0.0005,0);
  return normalize(
    vec3(
      map(pos+e.xyy).d,
      map(pos+e.yxy).d,
      map(pos+e.yyx).d
    )-map(pos).d
  );
}

// https://www.shadertoy.com/view/MtsGWH
vec4 boxmap( in sampler2D s, in vec3 p, in vec3 n, in float k )
{
    // project+fetch
	vec4 x = texture( s, p.yz );
	vec4 y = texture( s, p.zx );
	vec4 z = texture( s, p.xy );
    
    // and blend
  vec3 m = pow( abs(n), vec3(k) );
	return (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
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
    z += d;
  }

  return RM(z, hit);
}



vec3 getReflectCol(vec3 rd, vec3 nor, vec3 p){
  vec3 ref_rd = reflect(rd, nor);
  vec3 ref_ro = p;
  float z = rayMarch(ref_ro, ref_rd, .1, 10.).z;
  vec3 pos = ref_ro + ref_rd * z;

  Obj o = map(pos);
  vec3 col = getObjCol(pos, o.id);
  return col;
}

vec3 getRefractCol(vec3 rd, vec3 nor, vec3 p){
  vec3 ref_rd = refract(rd, nor, 1.5);
  vec3 ref_ro = p;
  float z = rayMarch(ref_ro, ref_rd, .1, 10.).z;
  vec3 pos = ref_ro + ref_rd * z;

  Obj o = map(pos);
  vec3 col = getObjCol(pos, o.id);
  return col;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  vec3 rd = normalize(vec3(uv, 1.));
  // vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 3.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  vec3 col = vec3(0);
  if(hit) {
    vec3 p = ro + rd * z;

    vec3 nor = calcNormal(p);
    // vec3 objCol = boxmap(iChannel0, p*.1, nor, 7.).rgb;
    
    Obj obj = map(p);
    col = getObjCol(p, obj.id);

    


    // 反射
    // vec3 col_reflect = getReflectCol(rd, nor, p);
    // col += col_reflect*.5;
    // col *= col_reflect;

    // 折射
    vec3 col_refract = getRefractCol(rd, nor, p);
    col += col_refract * .5;

    

    // vec3 l_dir = normalize(vec3(4,4,-4)-p);
    // float diff = max(0., dot(l_dir, nor));
    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    // // float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);
    // float fre = pow(max(1.-dot(nor, -rd),0.), 4.);
    // col = col * (diff + spe + fre*.1);

    // col *= calcAO(p, nor);
  }

  // col *= exp(-1e-4*z*z*z);
  col = pow(col, vec3(.4545));
  O.rgb = col;

}