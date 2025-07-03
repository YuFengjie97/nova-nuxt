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


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://www.shadertoy.com/view/XtGfzw
float sdCross( in vec2 p, in vec2 b, float r ) 
{
    p = abs(p); p = (p.y>p.x) ? p.yx : p.xy;
    vec2  q = p - b;
    float k = max(q.y,q.x);
    vec2  w = (k>0.0) ? q : vec2(b.y-p.x,-k);
    return sign(k)*length(max(w,0.0)) + r;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-20.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;
  vec3 p;


  for(float i =0.;i<100.;i++){
    p = ro + rd * z;

    p.xz *= rotate(T*.5);
    p.xy *= rotate(T*.5);
    
    // p.xz *= mix(0.3,1.,S(0.,.7,abs(sin(p.y*0.3)*.5)));
    d = sdCross(p.xz, vec2(4,1), 0.);
    d = length(vec2(d,p.y))-2.;
    d = sdCross(vec2(d,p.y), vec2(4,1), 0.);

    d = abs(d)+0.01;
    // d = max(0.001, d);

    O.rgb += (1.1+sin(vec3(3,2,1)+p.x*0.2-T))/d;
    z += d*.5;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 6e3);
}