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

  vec3 ro = vec3(0,0,-60.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  float r = 6.;

  for(float i =0.;i<300.;i++){
    vec3 p = ro + rd * z;

    // p.xz *= rotate(T);
    // p.xy *= rotate(T);

    p.xz *= rotate(p.y*0.1+T);


    // domain repetition https://iquilezles.org/articles/sdfrepetition/
    vec3 q = p;
    float s = 10.;
    vec2 id = floor(q.xz / s);
    vec2  o = sign(p.xz-s*id);

    for(float x=0.;x<2.;x++){
      for(float y=0.;y<2.;y++){
        vec2 rid = id + vec2(x,y)*o;
        rid = clamp(rid, -2., 2.);
        vec2 r = p.xz - s*rid; 
        float d1 = length(r-vec2(5.)) - (sin(dot(id,id))+1.1);
        d1 = max(0.01,d1*.2);
        d = min(d, d1);
      }
    }
    
    O.rgb += (1.1+sin(vec3(3,2,1)+(id.x+id.y)*2.))/d;
    z += d;
    if(z>80. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 5e4);

}