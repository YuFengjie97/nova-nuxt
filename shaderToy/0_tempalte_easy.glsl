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

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  // ro.z -= T;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xy *= rotate(p.z*0.1);

    float s = 5.;
    vec2 id = round(p.xy/s);
    id = clamp(id, -1., 1.);

    for(float x=-1.;x<=1.;x++){
      for(float y=-1.;y<=1.;y++){

        vec2 q = p.xy - s*(id + vec2(x,y));
        // vec2 q = p.xy - s*id;
        
        float d1 = length(q-vec2(1.))-(sin(p.z+T)*0.3+0.4);
        // d1 = abs(d1)+0.11;
        
        d1 = max(0.001, d1);
        d = min(d, d1);
      }
    }

    O.rgb += (1.1+sin(vec3(3,2,1)+(p.z)*0.2+(id.x+id.y)))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e5);
}