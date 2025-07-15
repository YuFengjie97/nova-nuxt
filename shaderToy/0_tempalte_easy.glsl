#define T iTime
#define PI 3.141596
#define S smoothstep


float map(vec3 p) {
  float d = length(p)- 4.;
  return d;
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
  float zMax = 100.;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    float d = map(p);
    if(d<1e-3) break;
    z += d;
    if(z>zMax) break;
  }

  if(z<zMax) {
    vec3 col = vec3(1,0,0);
    vec3 p = ro + rd * z;
    vec3 nor = calcNormal(p);
    float diff = clamp(dot(nor, vec3(0,0,-4)),0.,1.);
    O = vec4(col*diff, 1);
  }
}