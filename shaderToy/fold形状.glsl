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


vec3 fold(vec3 p) {
	vec3 nc = vec3(-.5, -.809017, .309017);
	for (int i = 0; i < 5; i++) {
		p.xy = abs(p.xy);
		p -= 2.*min(0., dot(p, nc))*nc;
	}
	return p - vec3(0, 0, 1.275);
}

float crystal(vec3 p, float scale) {
	vec3 fp = fold(p * scale);

	float cryst = dot(fp, normalize(sign(fp))) - .23 - sin(fp.y*.8)*1.6 - sin(fp.y*.7)*1.;
	cryst += min(fp.x*1., sin(fp.y*.3));

	fp = fold(fp) - vec3(.2, 0, -.1);
	fp = fold(fp) - vec3(-.1, 3.89, -.3);
	fp = fold(fp) - vec3(0, .1, .1);
	cryst += sin(fp.y*.27)*4.;
	cryst *= .55;

	return cryst / scale;
}


float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


vec4 map(vec3 p) {
  p.xy *= rotate(T*.5);
  p.xz *= rotate(T*.5);

  vec3 fp = fold(p);
  fp = fold(fp) - (sin(vec3(.3,.2,.1)+T)*.2+.3);
  fp = fold(fp) - vec3(.2);

  float d1 = length(fp)-.2;
  float d2 = sdBox(fp, vec3(.3));
  float d = mix(d1, d2, sin(T*4.)*.5+.5);
  
  vec3 col = sin(vec3(3,2,1)+fp.y*4.+T)*.5+.5;

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

vec3 light(vec3 l_dir, vec3 nor, vec3 rd){
  vec3 col;
  float diff = max(0., dot(l_dir, nor));

  // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
  float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 80.);

  col = vec3(.7 + diff + spe);
  return col;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-7.);
  // ro.xz = vec2(cos(T), sin(T))*10.;

  vec3 rd = normalize(vec3(uv, 1.));
  // vec3 rd = normalize(setCamera(ro, vec3(0), 0.)*vec3(uv, 1.));

  float zMax = 50.;

  float z = rayMarch(ro, rd, 0.1, zMax);

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    // col = boxmap(iChannel0, p*.2, nor, 7.).rgb;
    col = map(p).rgb;

    col *= light(normalize(vec3(0)-p),nor,rd);
    col *= light(normalize(vec3(10,10,-15)-p),nor,rd);

    col *= calcAO(p, nor);
  }

  // col *= exp(-1e-4*z*z*z);
  // col = pow(col, vec3(.5));
  O.rgb = col;

}