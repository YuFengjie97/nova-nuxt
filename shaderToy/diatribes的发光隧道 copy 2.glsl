

#define T iTime
#define t_path T*0.
#define s1(v) (sin(v)*.5+.5)
// #define P(z) vec3(cos((z)*.1)*5.,sin((z)*.1)*4.,(z))
// #define P(z) vec3(0,0,z)
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash13(vec3 p3){
  p3  = fract(p3 * .1031);
  p3 += dot(p3, p3.zyx + 31.32);
  return fract((p3.x + p3.y) * p3.z);
}

float noise(vec3 p){
  return dot(cos(p), vec3(.1,.2,.3));
}

float tun(vec3 p){
  p.x = abs(p.x);
  float d = min(10.-p.y-p.x, p.y+8.);
  return d;
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
// knighty  https://www.shadertoy.com/view/XlX3zB
vec3 fold(vec3 p) {
	vec3 nc = vec3(-.5, -.809017, .309017);
	for (int i = 0; i < 5; i++) {
		p.xy = abs(p.xy);
		p -= 2.*min(0., dot(p, nc))*nc;
	}
	return p - vec3(0, 0, 1.275);
}
vec4 col_glow = vec4(0);
float map(vec3 p){

  // vec3 path = P(p.z);
  // p.xy -= path.xy;
  vec3 q = p;
  float d = tun(q);

  {
    vec3 q = p;
    q.xy -= vec2(cos(T), sin(T))*4.;
    q.yz *= rotate(T);
    q.xz *= rotate(T);

    float d1 = sdBoxFrame(q, vec3(1.3), .1);
    // d1 = abs(d1) + .01;
    d = min(d, d1);
    col_glow += vec4(0,.6,0,1.)/max(d1, .01);
  }
  


  return d;
}


// https://www.shadertoy.com/view/4ttSWf
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);           
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  
	vec3 cu = normalize( cross(cw,cp) );  
	vec3 cv = normalize( cross(cu,cw) );  
  return mat3( cu, cv, cw );
}
// https://iquilezles.org/articles/normalsSDF/
vec3 getNormal(vec3 p){
  const float h = .001;
  const vec2 k = vec2(1,-1);
  vec3 n = normalize(k.xyy*map( p + k.xyy*h ) + 
                     k.yyx*map( p + k.yyx*h ) + 
                     k.yxy*map( p + k.yxy*h ) + 
                     k.xxx*map( p + k.xxx*h ) );
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O *= 0.;

  vec3 p;
  float z=0.;
  // vec3 ro = P(t_path);
  // vec3 ta = P(t_path+2.0);
  vec3 ro = vec3(0,0,-20.);
  vec3 ta = vec3(0,0,0);

  vec3 rd = setCamera(ro, ta, 0.) * normalize(vec3(uv, 1.));

  for(float i=0.;i<60.;i++){
    p = ro+rd*z;
    float d = map(p);
    z += d;
    O += col_glow + .1/max(d, .01);
  }
  vec3 nor = getNormal(p);


  rd = reflect(rd, nor);
  ro = p+nor*.1;
  z = 0.;
  col_glow *= 0.;
  vec4 col_ref = vec4(0);
  for(float i=0.;i<30.;i++){
    p = ro + rd * z;
    float d = map(p);
    z += d;
    col_ref += col_glow + .1/max(d,.01);
  }
  O += O * col_ref * .1;

  for(float j=0.;j<2.;j++){
    nor = getNormal(p);
    rd = reflect(rd, nor);
    ro = p+nor*.1;
    z = 0.;
    col_glow *= 0.;
    col_ref *= 0.;
    for(float i=0.;i<30.;i++){
      p = ro + rd * z;
      float d = map(p);
      z += d;
      col_ref += col_glow + .1/max(d,.01);
    }
    O += O * col_ref * .1;
  }


  O = tanh(O/1e7);
}