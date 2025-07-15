#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"


#define T iTime
#define PI 3.141596
#define S smoothstep
#define st(v) (sin(v*T)*.5+.5)

float hash21(vec2 p) {
  float x = dot(p, vec2(.4, .2));
  return abs(cos(x+sin(x*5.)/5.));
}

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

vec3 map(vec3 p){
  vec3 q = p;
  float d = -abs(q.y)+10.;   // up and down plane

  if(q.y<0.){
    q.x += 43.;
  }
  q.y = abs(q.y);
  q.y -= 10.;


  // // domainrepetition https://iquilezles.org/articles/sdfrepetition/
  float s = 2.;
  vec2 id = round(q.xz/s);
  vec2  o = sign(q.xz-s*id);
  for( int x=0; x<2; x++ ){
  for( int y=0; y<2; y++ ){
    vec2 rid = id + vec2(x,y)*o;
    vec3 r = q;
    r.xz -= s*rid;
    float n = hash21(rid*(st(.1)*.1+.5)+T*.5);
    float h = n*4.+2.;
    float s = n*.5+.2;

    d = min( d, sdBox(r, vec3(s, h, s)));
  }}

  return vec3(d, id);
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

// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy ).x + 
                      e.yyx*map( pos + e.yyx ).x + 
                      e.yxy*map( pos + e.yxy ).x + 
                      e.xxx*map( pos + e.xxx ).x );
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z=0.;
  float zMax = 100.;
  vec2 id=vec2(0,0);
  vec3 p;
  for(float i =0.;i<100.;i++){
    p = ro + rd * z;
    p.xz*=rotate(T*.5);
    p.z += T*2.;;

    vec3 M = map(p);
    float d = M.x;
    id = M.yz;

    if(d<1e-3) break;
    z += d;
    if(z>zMax) break;
  }

  if(z<zMax){
    vec3 nor = calcNormal(p, .001);
    // float diff = dot(nor, vec3(.2));
    // O = vec4((1.1+sin(vec3(1,2,3)+id.x+id.y))*diff, 1);

    vec3 col = boxmap(iChannel0, fract(p*.04+vec3(id,1.)), nor, 7.).rgb;
    // AO handler https://www.shadertoy.com/view/MtsGWH
    float occ = clamp(0.4 + 0.6*nor.x, 0.0, 1.0);
    col = col*col;
    col *= occ;
    col *= 2.0;
    col = sqrt( col );
    O = vec4(col, 1.);
  }
}