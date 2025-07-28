// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"


/*
灵感来自:
https://www.shadertoy.com/view/WXcGD2
https://www.shadertoy.com/view/MtBcDd
*/

#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float glow = 0.;
//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
	return pow(radius / max(dist, 1e-6), intensity);	
}


float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

struct Surface{
  float d;
  vec3 col;
};

Surface map(vec3 p) {
  vec3 q = p;

  p.yz *= rotate(p.x*.2+T);
  float d = sdBox(p.yz, vec2(1.6));
  float d1 = sdBox(p.yz, vec2(1.4));
  d = max(d, -d1);
  d += max(sin((p.x)*10.) * .4, 0.);
  d *= .08;
  vec3 col = sin(vec3(3,2,1)+(q.x)*.2+T*4.)*.5+.5;
  
  float d2 = length(q-vec3(sin(T*2.)*4.,0,0)) - .2;
  d = min(d, d2);
  glow += getGlow(d2, .8, 1.4);

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
  for(float i=0.;i<400.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).d;
    if(d<1e-3 ){
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

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-5.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  float t = fract(T / 6.);
  if(t<.5){
    ro = vec3(5,0,-1);
  }


  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 1.));



  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  vec3 col = vec3(0);
  if(hit) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    // vec3 objCol = boxmap(iChannel0, p*.1, nor, 7.).rgb;
    vec3 objCol = map(p).col;
    // vec3 objCol = vec3(1,0,0);

    float amb = .5;
    vec3 ambCol = vec3(1);
    col += objCol * amb * ambCol;

    vec3 l_dir = normalize(vec3(0,0,-5));
    float diff = max(0., dot(l_dir, nor));
    col += objCol * diff;

    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 90.);
    col += objCol * spe;

    col *= calcAO(p, nor);
  }

  col += glow*.01;

  // col = pow(col, vec3(.5));
  O.rgb = col;

}