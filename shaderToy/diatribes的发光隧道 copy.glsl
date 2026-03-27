

#define T iTime
#define t_path T*10.
#define s1(v) (sin(v)*.5+.5)
#define P(z) vec3(cos((z)*.1)*4.,sin((z)*.1)*4.,(z))
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
  p = abs(p);
  float d = min(-p.x+7., 5.-p.y);
  // float d = min(-p.y-.5*p.x+5., 3.-p.y);
  
  return d;
}


// 其实都在发光 glow_r/sdf
vec3 col_glow = vec3(0);
vec3 col_base = vec3(0);
float map(vec3 p){
  vec3 path = P(p.z);
  p.xy -= path.xy;
  vec3 q = p;

  p += floor(sin(p.yzx*.1+T))*.8;
  p += floor(sin(p.yzx*.2))*.4;

  float d = tun(p);
  col_base += vec3(.1,.01,.4)/max(d, .01);
  {
    q.xy = abs(q.xy);
    q.xy -= 2.5;
    float d1 = length(q.xy)-.1;
    // q.z = cos(q.z);
    // float d1 = sdBoxFrame(q, vec3(.1,.2,.3), .01);
    col_glow += vec3(.1,.2,0)/max(d1, .01);  
    d = min(d, d1);
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
  const float h = .0001;
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

  O.rgb *= 0.;
  O.a = 1.;

  vec3 p;
  float z=0.;
  vec3 ro = P(t_path);
  vec3 ta = P(t_path+2.0);
  vec3 rd = setCamera(ro, ta, sin(T*.3)*.1) * normalize(vec3(uv, 1.));

  for(float i=0.;i<100.;i++){
    p = ro+rd*z;
    float d = map(p)*.6;
    z += d;
  }
  vec3 nor = getNormal(p);

  O.rgb += col_base;
  O.rgb += col_glow ;
  O.rgb = tanh(O.rgb/4e2);


  rd = reflect(rd, nor);
  ro = p+nor*.1;
  z = 0.;
  col_glow *= 0.;
  col_base *= 0.;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    z += map(p);
  }
  O.rgb += O.rgb * col_glow;
  O.rgb = tanh(O.rgb/1e1);

}