#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define eee(v) (1.-exp(-v*5.))

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



vec4 map(vec3 p) {
  p.xz *= rotate(T * .5);
  p.yz *= rotate(T * .5);

  float d1 = length(p)-4.;
  float d2 = sdBox(p, vec3(3));
  float d3 = sdOctahedron(p, 4.);
  float d4 = sdBoxFrame(p, vec3(3), .4);

  float t = mod(T/5., 4.);
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

  vec3 col = .4+.4*sin(vec3(3,2,1)+(p.x+p.y+p.z)*.4);
  return vec4(col, d);
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

vec3 phong(vec3 col, vec3 rd, vec3 nor, vec3 l_dir){
  // 漫反射
  float diff = clamp(dot(nor, l_dir), 0., 1.);
  col *= diff*.5;

  // 高光
  vec3 col_spe = vec3(1.);
  // float spe = clamp(dot(reflect(l_dir, nor),     rd), 0., 1.);
  float spe    = clamp(dot(normalize(l_dir - rd),   nor), 0., 1.);  // 半程向量
  col += col_spe * pow(spe, 16.) * 1.;

  return col;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 100.;
  float z = rayMarch(ro, rd, .1, zMax);

  vec3 col = vec3(.0);  // bg color
  if(z<zMax){
    vec3 p = ro + rd * z;
    vec4 M = map(p);
    col = M.rgb;
    vec3 nor = calcNormal(p);

    col += phong(col, rd, nor, normalize(vec3(4,4,-5)                 -p));
    col += phong(col, rd, nor, normalize(vec3(cos(T)*5.,-4.,sin(T)*5.)-p));
  }

  // fog
  col *= exp(-2e-3*z*z*z);

  // gamma
  O.rgb = pow(col, vec3(1./2.2));

  O.rgb = col;
}