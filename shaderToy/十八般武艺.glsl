#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define eee(v) (1.-exp(-v*5.))

const float PRECISION = 0.001;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


// https://iquilezles.org/articles/distfunctions/
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float sdOctahedron( vec3 p, float s )
{
  p = abs(p);
  float m = p.x+p.y+p.z-s;
  vec3 q;
       if( 3.0*p.x < m ) q = p.xyz;
  else if( 3.0*p.y < m ) q = p.yzx;
  else if( 3.0*p.z < m ) q = p.zxy;
  else return m*0.57735027;
    
  float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
  return length(vec3(q.x,q.y-s+k,q.z-k)); 
}

float map(vec3 p) {
  float dd = p.y+3.;

  float d1 = length(p)-1.;
  float d2 = sdBox(p, vec3(1.));
  float d3 = sdOctahedron(p, 1.);
  float d4 = sdBoxFrame(p, vec3(1), .1);

  float t = mod(T/2., 4.);
  float ti = floor(t);
  float tf = fract(t);
  float d;
  if(ti==0.){
    d = mix(d1, d2, eee(tf));
  }
  else if(ti==1.){
    d = mix(d2, d3, eee(tf));
  }
  else if(ti==2.){
    d = mix(d3, d4, eee(tf));
  }
  else if(ti==3.){
    d = mix(d4, d1, eee(tf));
  }

  return min(dd, d);
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

float rayMarch(vec3 ro, vec3 rd){
  float zMax=100.;
  float z;
  vec3 p;
  float d;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    d = map(p);
    if(d<PRECISION || z>zMax) break;
    z+=d;
  }
  return z;
}


// https://iquilezles.org/articles/rmshadows/
float softShadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float res = 1.0;
  float t = mint;

  for(int i = 0; i < 100; i++) {
      float h = map(ro + rd * t);
      res = min(res, 8.0*h/t);
      t += clamp(h, 0.02, 0.10);
      if(h < 0.001 || t > tmax) break;
  }

  return clamp( res, 0.0, 1.0 );
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb = vec3(0);  // backgroud color
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-5.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = rayMarch(ro, rd);
  vec3 p = ro + rd * z;

  if(z<100.) {
    // 设置材质
    vec3 nor = calcNormal(p);
    vec3 col = boxmap(iChannel0, fract(p*.1), nor, 7.).rgb;
    O = vec4(col, 1);
    // O.rgb = vec3(.5);


    // 光照明
    // vec3 lightPos = vec3(cos(T*.1)*6.,3,sin(T*.1)*6.);
    vec3 lightPos = vec3(4, 4, -4.);
    vec3 lightDir = normalize(lightPos-p);
    float diff = clamp(dot(lightDir, nor),0.,1.);

    #if 0
    // 普通阴影+简单的漫反射
    float shadowLen = rayMarch(p+nor*PRECISION, lightDir);
    if(shadowLen < length(lightPos-p)){
      diff*=0.1;  // 不是0,简单模拟漫反射
    }
    O.rgb = O.rgb * diff;
    #else
    // 柔和阴影
    float ss = clamp(softShadow(p, lightDir, .1, 10.), 0., 1.0);
    O.rgb = diff * O.rgb * ss;
    #endif

    // 高光
    vec3 ref = reflect(lightDir, nor);
    float spe = clamp(dot(ref, -rd),0.,1.);
    O.rgb += vec3(1,0,0)*pow(spe, 10.);

    // fog
    // O.rgb = mix(O.rgb, vec3(0.), 1.0 - exp(-0.00002 * pow(z, 3.)));
    O.rgb *= exp(-.0005*z*z*z);
  }
   // 伽马校正
  O.rgb = pow(O.rgb, vec3(1./2.));
}