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


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-22.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xy *= rotate(T*.5);
    p.xz *= rotate(T*.5);
    // p.yz *= rotate(T*.5);

    vec3 q = p;
    vec3 id = round(q/4.)*4.;
    q -= id;

    q-=cos(id);

    float r = .5;
    float d1 = length(q.yz)-r; 
    float d2 = length(q.xy)-r; 
    float d3 = length(q.xz)-r;
    d = min(d1,min(d2,d3));


    {
      vec3 q = p;
      q = abs(q) - vec3(10.);
      float box = max(max(q.x,q.y),q.z);
      d = max(d, box);
    }

    d = max(0.01,d*.6); 
    O.rgb += (1.1+sin(vec3(3,2,1)+(p.x+p.y+p.z)*0.1+T))/d;

    z += d;

    if(z>50. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

  // vec2 d1 = abs(uv) - vec2(0.5,0.2);
  // float s = length(max(d1,0.0));
  // O.rgb += s;
}