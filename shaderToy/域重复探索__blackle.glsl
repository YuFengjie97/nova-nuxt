// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-5;



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
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0)-.01;
}


float hash122(vec2 v){
  return fract(sin(dot(v, vec2(5645.455,633.233)))*124.544);
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
vec2 edge(vec2 p) {
    vec2 p2 = abs(p);
    if (p2.x > p2.y) return vec2((p.x < 0.) ? -1. : 1., 0.);
    else             return vec2(0., (p.y < 0.) ? -1. : 1.);
}


//nonzero sign function
float nonZeroSign(float x) {
  return sign(x);
  return x < 0. ? -1. : 1.;
}

vec3 face(vec3 p) {
    vec3 ap = abs(p);
    if (ap.x>=max(ap.z,ap.y)) return vec3(nonZeroSign(p.x),0.,0.);
    if (ap.y>=max(ap.z,ap.x)) return vec3(0.,nonZeroSign(p.y),0.);
    if (ap.z>=max(ap.x,ap.y)) return vec3(0.,0.,nonZeroSign(p.z));
    return vec3(0);
}

Obj map(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    p.xz*=rotate(m.x);
    p.yz*=rotate(m.y);
  }

  vec2 id = floor(p.xz);
  id = clamp(id, -3., 3.);
  float size = .48;
  float h = sin(id.x+id.y*2.+T)*2.+2.;
  #define useEdge

  #ifdef useEdge
  vec2 cen = id + .5;
  vec2 nei = cen + edge(p.xz-cen);
  float d  = sdBox(p-vec3(cen.x,0.,cen.y), vec3(size, h, size));
  float d1 = sdBox(p-vec3(nei.x,0.,nei.y), vec3(size, 4., size));
  d = min(d, d1);
  #else
  vec3 cen = vec3(id.x+.5, p.y, id.y+.5);
  vec3 nei = cen + face(p-cen);
  float d  = sdBox(p-vec3(cen.x,0.,cen.z), vec3(size, h, size));
  float d1 = sdBox(p-vec3(nei.x,0.,nei.z), vec3(size, 4., size));
  d = min(d, d1);
  #endif

  return Obj(d, id.x+id.y);
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
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  // uv *= 4.;
  // vec2 id = round(uv);
  // vec2 o = sign(uv - id);
  // float d = 1e20;
  // for(float x=0.;x<2.;x++){
  // for(float y=0.;y<2.;y++){
  //   vec2 idd = id + o * vec2(x,y);
  //   vec2 uv2 = uv - idd;
  //   float n = hash12(idd);
  //   float d1 = sdBox(uv2, vec2(n*.8,n*.8));
  //   d = min(d, d1);
  // }
  // }
  // vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
	// col *= 1.0 - exp(-10.0*abs(d));
	// col *= 0.8 + 0.2*cos(50.0*abs(d));
	// col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.02,abs(d)) );
  // O.rgb = col;


  vec3 ro = vec3(0.,6.,-10.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

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
    col = s1(vec3(3,2,1)+obj.id);;

    vec3 l_dir = normalize(vec3(4,10,-4));
    float diff = max(0., dot(l_dir, nor));

    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);

    float fre = pow(max(1.-dot(nor, -rd),0.),3.);
    col = col * diff + spe;

    // col *= calcAO(p, nor);
  }

  col *= exp(-1e-4*z*z*z);
  // col = pow(col, vec3(.4545));
  O.rgb = col;

}