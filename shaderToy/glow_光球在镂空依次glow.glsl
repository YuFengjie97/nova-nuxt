
/*
灵感来自:
https://www.shadertoy.com/view/WXcGD2
https://www.shadertoy.com/view/MtBcDd

AA:  https://www.shadertoy.com/view/lsKcDD

domainRepetition: https://iquilezles.org/articles/sdfrepetition/

previous version: https://www.shadertoy.com/view/WX3XRf
*/

#define T iTime
#define PI 3.141596
#define S smoothstep

// make this 1 is your machine is too slow
#define AA 2

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash(float v){
  return abs(dot(cos(vec3(v)), vec3(.04)));
}

vec3 glowCol = vec3(0);
//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
	return pow(radius / max(dist, 1e-6), intensity);	
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

struct Surface{
  float d;
  vec3 col;
};

Surface map(vec3 p) {
  vec3 q = p;
  q.x -= T*.6;
  vec3 col = vec3(.4);
  float d = 1e4;

  float s = .2;
  float id = round(q.x/s);
  q.x -= id*s;
  q.yz *= rotate(id*.1+T);

  {
    float size = .4;
    float thickness = .04;
    float d1 = sdBox(q, vec3(thickness, size, size))-.004;
    float d2 = sdBox(q, vec3(thickness+1.,size-.04,size-.04))-.004;
    d1 = max(d1, -d2);
    d = d1*.2;
  }

  col = sin(vec3(3,2,1)+id)*.5+.5;

  float n = abs(sin(id*.3+T*.8));
  if(n<.2){
    glowCol += getGlow(d, .008, 2.)*.1 * col;
  }

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
  
  vec3 tot = vec3(0.0);
  #if AA>1
  for( int m=0; m<AA; m++ )
  for( int n=0; n<AA; n++ )
  {
    vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5;
    vec2 uv = ((I+o)*2.-R)/R.y;
  #else  
  vec2 uv = (I*2.-R)/R.y;
  #endif

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-2.);
  vec3 ta = vec3(0,0,0);

  float t = fract(T / 12.);
  if(t<.3){
    ro.z = -1.;
    ta = vec3(-4,0,0);
  }else if(t<.6){
    ro = vec3(0);
    ta = ro - vec3(3,0,0);
  }
  
	vec2 m = iMouse.xy/iResolution.xy;
  if(iMouse.z>0.){
    ro.yz *= rotate(m.y*PI*2.);
    ro.xz *= rotate(m.x*PI*2.);
  }
  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, ta, 0.) * normalize(vec3(uv, 1.));



  float zMax = 20.;

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


    vec3 l_dir = normalize(vec3(0,5,-5));
    float diff = max(0., dot(l_dir, nor));
    col += objCol * diff * 2.;

    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 90.);
    col += col * spe * 3.;

    // col = pow(col, vec3(.5));

    col *= calcAO(p, nor);
  }

  glowCol = 1.-exp(-glowCol);

  col += glowCol;
  tot += col;

  // tot *= exp(-5e-4*z*z*z);

  #if AA>1
    }
    tot /= float(AA*AA);
  #endif

  O.rgb = tot;

}