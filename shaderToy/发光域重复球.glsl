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

float hash21(vec2 p){
  return abs(dot(cos(p), vec2(.5)));
}
float glow = 0.;
vec4 map(vec3 p) {
  float s = 1.;
  vec2 id = round(p.xz/s);
  // id = clamp(id, -10.,10.);

  vec2  o = sign(p.xz-s*id);
  float d = 1e20;
  for( int j=0; j<2; j++ )
  for( int i=0; i<2; i++ )
  {
      vec2 rid = id + vec2(i,j)*o;
      float yoff = hash21(rid*.5+T);

      vec2 r = p.xz - s*rid;
      float d1 = length(vec3(r.x,p.y,r.y)-vec3(0,yoff,0))- .35;
      d = min( d, d1);
  }
  float n = hash21(id);
  if(n<.01){
    glow += 0.01/(d*d);
  }

  vec3 col = sin(vec3(3,2,1)+n*10.)*.5+.5;
  return vec4(col, d);
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( -cu, cv, cw );
}

// https://www.shadertoy.com/view/lsKcDD
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = map( pos + h*nor ).w;
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
            e.xyy*map( pos + e.xyy*eps ).w + 
					  e.yyx*map( pos + e.yyx*eps ).w + 
					  e.yxy*map( pos + e.yxy*eps ).w + 
					  e.xxx*map( pos + e.xxx*eps ).w );
}

vec3 calcNormal2(vec3 pos){
  vec2 e = vec2(0.0005,0);
  return normalize(
    vec3(
      map(pos+e.xyy).w,
      map(pos+e.yxy).w,
      map(pos+e.yyx).w
    )-map(pos).w
  );
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
    float d = map(p).w;
    if(d<1e-3){
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

  vec3 ro = vec3(0.,4.,-6.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  vec3 rd = normalize(setCamera(ro, vec3(0), 0.)*vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  float z = rm.z;
  bool hit = rm.hit;

  vec3 col = vec3(0);
  if(hit) {
  // if(z<zMax) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    col = map(p).rgb;

    vec3 l = normalize(vec3(cos(T)*20.,4,sin(T)*20.));
    float dir = max(0., dot(l, nor));
    col = mix(col, vec3(1), dir*.5);

    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    float spe = pow(max(0., dot(normalize(l-rd), nor)), 30.);
    col += spe;
    // col *= calcAO(p, nor);
  }
  col += glow*.1;

  col *= exp(-5e-4*z*z*z);
  // col = pow(col, vec3(.5));
  O.rgb = col;

}