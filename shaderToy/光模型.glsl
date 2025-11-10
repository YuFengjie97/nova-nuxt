// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-3;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float opSmoothUnion( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float opSmoothSubtraction( float d1, float d2, float k )
{
    return -opSmoothUnion(d1,-d2,k);
}
float map(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    p.xz = rotate(m.x)*p.xz;
    p.yz = rotate(m.y)*p.yz;
  }
  float d = sdRoundBox(p, vec3(3.), .1);
  {
    vec3 q = p;
    q.xy = abs(q.xy);
    q.xy = rotate(PI/4.)*q.xy;
    float d1 = sdTorus( q, vec2(5, .4));
    d = opSmoothUnion(d, d1,.1);
  }
  {
    vec3 q = p;
    q.xy = abs(q.xy);
    q.x -= 2.;

    float d1 = length(q)-3.;
    d = opSmoothSubtraction(d1, d, .1);
  }
  

  return d;
}


// https://www.shadertoy.com/view/lsKcDD
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = map( pos + h*nor );
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
              e.xyy*map( pos + e.xyy*eps ) + 
              e.yyx*map( pos + e.yyx*eps ) + 
              e.yxy*map( pos + e.yxy*eps ) + 
              e.xxx*map( pos + e.xxx*eps ) );
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
  bool hit;
  float z;
};

RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }
  return RM(hit, z);
}

vec3 Tonemap_ACES(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (x * (a * x + b)) / (x * (c * x + d) + e);
}

float sRGB(float t) { return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }


struct Light{
  float amb;
  float diff;
  float spe;
};

/*
l_dir并不是语义上的光源方向,
在learnopengl上,并且约定是,由物体指向光源的向量
注意在你直接传入某个向量时,它不是光源位置,而是 -光的射向
注意实现,默认l_dir是由物体上位置射向光位置
*/
Light getLight(vec3 l_dir, vec3 nor, vec3 rd, float amb){
  float diff = max(0., dot(l_dir, nor));
  float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 30.);
  return Light(amb, diff, spe);
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


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 1.));

  float zMax = 40.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  vec3 col = vec3(0,0,0);
  vec3 l_col = vec3(2);
  if(rm.hit) {
    vec3 p = ro + rd * rm.z;
    vec3 nor = calcNormal(p);

    vec3 obj_col = vec3(.5,.4,.6);

    // 平行光
    {
      Light l = getLight(normalize(-vec3(0,0,10)), nor, rd, .3);
      col = obj_col * (l.amb*.3 + l.diff*.6 + l.spe*3.)*l_col * .5;
    }

    // 点光源
    {
      vec3 l_dir = vec3(10,0,-10)-p;
      Light l = getLight(normalize(l_dir), nor, rd, .3);
      float attentution = 5./length(l_dir);
      col += obj_col * (l.amb*.3 + l.diff*.6 + l.spe*3.)*l_col*attentution;
    }

    // 反射
    {
      vec3 ref = reflect(rd, nor);
      float zMax = 10.;
      RM rm = rayMarch(p, ref, .01, zMax);
      if(rm.hit){
        col += obj_col*S(zMax,0.,rm.z)*.2;
      }
    }

    // col *= calcAO(p, nor);
  }

  // col *= exp(-1e-4*rm.z*rm.z);
  col = pow(col, vec3(1.5));
  // col = Tonemap_ACES(col);
  // col = sRGB(col);
  O.rgb = col;
}