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

vec4 map(vec3 p) {
  float d = length(p)- 4.;
  vec3 col = sin(vec3(3,2,1)+(p.x+p.y+p.z)*2.);
  // vec3 col = vec3(.5);
  return vec4(col, d);
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

float rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).w;
    if(d<1e-3 || z>zMax) break;
    z += d;
  }

  return z;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  vec3 rd = normalize(vec3(uv, 1.));
  // vec3 rd = normalize(setCamera(ro, vec3(0), 0.)*vec3(uv, 1.));

  float zMax = 100.;

  float z = rayMarch(ro, rd, 0.1, zMax);

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    // vec3 objColor = boxmap(iChannel0, p*.1, nor, 7.).rgb;
    vec3 objColor = map(p).rgb;

    vec3 l_dir = normalize(vec3(4,4,-4)-p);
    float diff = max(0., dot(l_dir, nor));

    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);

    col = (1. + diff + spe)*objColor;
    // col *= calcAO(p, nor);
  }

  col *= exp(-1e-4*z*z*z);
  // col = pow(col, vec3(.5));
  O.rgb = col;

}