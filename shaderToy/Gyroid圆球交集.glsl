// https://www.shadertoy.com/view/tlcXWX

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep



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

float sdGyroid(vec3 p){
  float s = 4.;
  p *= s;
  return (abs(dot(sin(p+T), cos(p.zxy)))-.4)/s;
}

// https://www.shadertoy.com/view/tlcXWX
float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0., 1. );
    return mix( b, a, h ) - k*h*(1.0-h);
}

struct Surface{
  float id;
  float d;
  vec3 col;
};

Surface map(vec3 p) {
  p.xz *= rotate(T*.3);
  float d_sphere = abs(length(p) - 4.)-.03;
  float d_gyroid = sdGyroid(p)*.6;
  float d = smin(d_sphere, d_gyroid, -.001);

  float id = 0.;
  vec3 col = sin(vec3(3,2,1)+(p.x+p.y+p.z)*.2);

  float d_cube = -sdBox(p, vec3(10.));
  if(d_cube<d){
    id = 1.;
    col = vec3(1);
  }
  d = min(d, d_cube);

  // vec3 col = vec3(.5);
  return Surface(id, d, col);
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


float rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).d;
    if(d<1e-3 || z>zMax) break;
    z += d;
  }

  return z;
}

// https://iquilezles.org/articles/rmshadows/
float softShadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float res = 1.0;
  float t = mint;

  for(int i = 0; i < 100; i++) {
      float h = map(ro + rd * t).d;
      res = min(res, 8.0*h/t);
      t += clamp(h, 0.02, 0.10);
      if(h < 0.001 || t > tmax) break;
  }

  return clamp( res, 0.0, 1.0 );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,1,-8.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = normalize(setCamera(ro, vec3(0), 0.)*vec3(uv, 1.));

  float zMax = 50.;

  float z = rayMarch(ro, rd, 0.1, zMax);

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    // vec3 objCol = boxmap(iChannel0, p*.1, nor, 7.).rgb;
    Surface sf = map(p);
    col = sf.col;
    float id = sf.id;
    vec3 l_pos = vec3(0);
    vec3 l_dir = normalize(l_pos-p);
    
    float diff = max(0., dot(l_dir, nor));

    if(id==0.){
      col *= diff*.5;
      float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 40.);
      col += spe;
    }
    if(id==1.){
      col *= diff;
      float ss = max(0., softShadow(l_pos, l_dir, 0.1, 50.));
      col *= ss*.5;
    }
    col *= calcAO(p, nor);
  }

  col = pow(col, vec3(.42));
  O.rgb = col;

}