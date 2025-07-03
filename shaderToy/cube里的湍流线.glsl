#define T iTime
#define PI 3.141596
#define S smoothstep


vec4 map(vec3 p) {
  vec3 col = vec3(0);
  float d = 0.;
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


float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  float d = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
  return d;
  // return abs(d)+0.1;
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

  vec3 ro = vec3(0.,0.,-11.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.xy *= rotate(T*0.3);
    p.xz *= rotate(T*0.3);

    vec3 q = p;

    float h = S(-10.,10.,p.y);
    p.x += cos(h*10.)*h*2.;
    p.z += sin(h*10.)*h*2.;

    for(float x=1.;x<5.;x++){
      p += sin((p.zxy + i + T) * x)/x;
    }

    float r = S(-1.,1.,p.y)*2.5;
    float line = length(p.xz)-r;
    line = max(0.01, line*.1);


    float cube = sdBox(q,vec3(4.));
    cube = abs(cube*.6) + 0.1;

    d = max(cube, line);
    O.rgb += (1.1+sin(vec3(4,0,2)+(p.y*.3+q.y*0.1)))/d/d;

    z += d;
    if(z>20. || d<1e-4) break;
  }

  O.rgb = tanh(O.rgb / 2e2);
}