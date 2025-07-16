#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep
#define eee(v) (1.-exp(-v*5.))

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
  float d1 = length(p)-4.;
  float d2 = sdBox(p, vec3(3));
  float d3 = sdOctahedron(p, 4.);
  float d4 = sdBoxFrame(p, vec3(3), .4);

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
  return d;
}


// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy ) + 
                      e.yyx*map( pos + e.yyx ) + 
                      e.yxy*map( pos + e.yxy ) + 
                      e.xxx*map( pos + e.xxx ) );
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


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float zMax = 20.;
  vec3 p;

  for(float i =0.;i<100.;i++){
    p = ro + rd * z;
    p.xz*=rotate(T*.5);
    p.yz*=rotate(T*.5);

    float d = map(p);
    if(d<1e-3) break;
    z+=d;
    if(z>zMax) break;
  }

  if(z<zMax){
    vec3 nor = calcNormal(p, 0.001);
    O.rgb = 1.1+sin(vec3(3,2,1)+p.x*.4);
    O.rgb = mix(O.rgb, boxmap(iChannel0, fract(p*.1), nor, 8.).rgb, .8);
  }
}