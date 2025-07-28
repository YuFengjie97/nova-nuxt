// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep

vec3 l_pos = vec3(0,2,2);
vec3 l_col = vec3(1);

float glow = 0.;
//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
	return pow(radius / max(dist, 1e-6), intensity);	
}

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

struct Surface{
  float d;
  vec3 col;
  float objId;
};


Surface map(vec3 p) {
  vec3 q = p;
  q.z += T;

  float s = 1.;
  vec2 id = round(vec2(q.xz)/s);
  q.xz -= id*s;
  float w = .3;
  float thickness = .04;
  float objId = 0.;

  float d = 1e4;

  vec3 col = vec3(0.);
  {
    float ww = w+.14;
    float dc = ww-clamp(abs(q.x),w,ww);
    // float dc = .1108-S(abs(q.x),0.,w)*w;  // Can't find value make smooth bend, the value .1108 is try many time
    float zz = mod(id.x+id.y,2.) > 0. ? -1. : 1.;
    float bend = zz*dc;
    float d1 = (sdBox(q + vec3(0,bend,0), vec3(1.,thickness,w))-.02)*.6;
    if(d1<d){
      col = sin(vec3(3,2,1)+id.y)*.5+.5;
    }
    d = min(d, d1);
  }
  {
    float d1 = sdBox(q + vec3(0,0,0), vec3(w,thickness,1.))-.02;
    if(d1<d){
      col = sin(vec3(3,2,1)+id.x)*.5+.5;
    }
    d = min(d, d1);
  }
  {
    float d1 = (length(p-l_pos)-.4);
    glow += getGlow(d1, .2, 2.);

    if(d1<d){
      objId = 1.;
    }
    // d = d1;
    d = min(d, d1);
  }
  return Surface(d, col, objId);
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
  RM rm;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    Surface ss = map(p);
    float d = ss.d;
    if(d<1e-3){
      rm.hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }
  rm.z = z;

  return rm;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
	vec2 m = iMouse.xy/iResolution.xy;
  l_col = sin(vec3(3,2,1)+T)*.4+.6;
  l_pos.xz += vec2(cos(T), sin(T))*6.;
  l_pos.y += sin(T)*2.+1.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,2.,-10.);
  if(iMouse.z>0.){
    ro.yz *= rotate(m.y*PI*2.);
    ro.xz *= rotate(m.x*PI*2.);
  }
  
  
  // ro.xz = vec2(cos(T*.4), sin(T*.4))*10.;

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = normalize(setCamera(ro, vec3(0), 0.)*vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  float z = rm.z;
  bool hit = rm.hit;

  vec3 col = vec3(0);
  if(hit) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    Surface ss = map(p);
    vec3 objCol = ss.col;
    if(ss.objId == 0.) {
      vec3 l_dir = normalize(l_pos-p);
      float diff = max(0., dot(l_dir, nor));
      col = objCol * diff;

      float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);
      col += spe * l_col;
    }

    col *= calcAO(p, nor);
  }
  col *= exp(-5e-4*z*z*z);

  col += l_col*glow;
  // col = pow(col, vec3(.8));
  O.rgb = col;

}