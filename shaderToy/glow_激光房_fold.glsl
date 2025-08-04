// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define R iResolution.xy

const float EPSILON = 1e-6;


float getGlow(float d, float r, float ins){
  return pow(r/d, ins);
}

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// knighty  https://www.shadertoy.com/view/XlX3zB
vec3 fold(vec3 p) {
	vec3 nc = vec3(-.5, -.809017, .309017);
	for (int i = 0; i < 5; i++) {
		p.xy = abs(p.xy);
		p -= 2.*min(0., dot(p, nc))*nc;
	}
	return p - vec3(0, 0, 1.275);
}

struct Obj{
  float d;
  float id;
};
Obj Obj_Union(Obj o1, Obj o2){
  if(o1.d<o2.d){
    return o1;
  }else{
    return o2;
  }
}

float hash(float v){
  return fract(sin(v*2321.23)*cos(fract(v*2.1345)));
}

float glow_arr[4] = float[4](0.,0.,0.,0.);
Obj obj_2(vec3 p, float ind){

  p = fold(p);
  float n = hash(ind+20.);
  p -= vec3(n, hash(ind+2.), hash(ind+4.))*ind*4.-ind*2.;

  p.xz *= rotate(n*2.+T*n*4.);
  p.yz *= rotate(n*4.+T*n*4.);

  p = fold(p);

  float d = length(p.xz)-.02;
  glow_arr[int(ind)] += getGlow(d, .04, 2.);

  float id = ind;
  return Obj(d, id);
}
vec3 obj_2_col(){
  vec3 col = vec3(.0);
  for(int i=0;i<4;i++){
    vec3 glow_col = sin(vec3(3,2,1)+float(i)*3.+T)*.5+.5;
    col += glow_col * glow_arr[i];
  }
  return col;
}


Obj map(vec3 p) {
  if(iMouse.z > 0.){
    vec2 m = iMouse.xy / R * 6.2;
    p.xz *= rotate(m.x);
    p.yz *= rotate(m.y);
  }
  Obj o = Obj(1e4, -1.);
  for(int i=0;i<4;i++){
    Obj o2 = obj_2(p, float(i));
    o = Obj_Union(o, o2);
  }
  return o;
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

float highLight(vec3 l_dir, vec3 rd, vec3 nor){
  float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 60.);
  return spe;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-6.);
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
  Obj o = map(p);
  // float diff = max(0., dot(normalize(vec3(0)-p), nor));
  // col += diff*.1;

  // float spe = highLight(normalize(vec3(cos(T),cos(T),sin(T))*4.), rd, nor);
  // col += spe * vec3(1,0,0);
  // {
  //   float spe = highLight(normalize(vec3(-3)), rd, nor);
  //   col += spe * vec3(1);
  // }

  // col *= calcAO(p, nor);
  
  // fog to origin center
  float dist_o = dot(p,p);
  col *= exp(-2e-4*dist_o*dist_o*dist_o);

  col += obj_2_col();
  
  col = pow(col, vec3(.4545));
  O.rgb = col;

}