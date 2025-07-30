// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const mat3 m3 = mat3(0.33338, 0.56034, -0.71817, -0.87887, 0.32651, -0.15323, 0.15162, 0.69596, 0.61339)*1.93;
const float EPSILON = 1e-6;


float fbm(vec3 p){
  float n = 0.;
  float fre = 1.;
  float amp = 1.;
  for(float i=0.;i<5.;i++){
    p += amp*sin(p.zxy*fre);
    n += abs(dot(cos(p), sin(p.yzx)));

    amp *= .5;
    fre *= 2.;
    p = p*m3;
  }

  return n;
}

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

struct Surface{
  float d;
  vec3 col;
};


float map(vec3 p) {

  p.xz *= rotate(T*.4);
  p.yz *= rotate(T*.4);

  float n = fbm(p*.2+vec3(T,T,0)*.1);

  float d = length(vec2(length(p.xy)-1.5,p.z))-.5;
  d += n*.1;
  d = max(0.,d*.2);

  return d;
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


struct RM{
  float z;
  bool hit;
};

float glow = 0.;
//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
	return pow(radius / max(dist, EPSILON), intensity);	
}

RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    glow += getGlow(d, 1e-5, .65);

    if(d<EPSILON){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }

  return RM(z, hit);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
	vec2 m = iMouse.xy/iResolution.xy;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-3.);
  vec3 ta = vec3(0);
  if(iMouse.z>0.){
    ro.xz *= rotate(m.x*PI*2.);
    ro.yz *= rotate(m.y*PI*2.);
  }
  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, ta, 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  float z = rm.z;
  bool hit = rm.hit;
  vec3 p = ro + rd * z;

  vec3 col = vec3(0);

  // vec3 objCol = boxmap(iChannel0, p*.1, nor, 7.).rgb;
  if(hit) {
    vec3 objCol = sin(vec3(3,2,1)+T);
    vec3 nor = calcNormal(p);
    col = objCol * .2;
    vec3 l_dir = normalize(vec3(0,5,0));
    float diff = max(0., dot(l_dir, nor));
    col += diff*.5;
  }

  
  vec3 glowCol = sin(vec3(3,2,1)+T)*.3+.5;
  vec3 col2 = glow*glowCol*.6;

  col = mix(col, col2, sin(T*.5)*.5+.5);

  col = pow(col, vec3(.4545));
  O.rgb = col;
}