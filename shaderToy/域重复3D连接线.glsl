#define T iTime
#define PI 3.141596
#define S smoothstep
#define dot2(v) dot(v,v)

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash31(vec3 v){
  return cos(dot(v, vec3(4.2,18.3,22.5)))*.5+.5;
}

// https://iquilezles.org/articles/distfunctions/
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-12.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    // p.xy *= rotate(T*.3);
    p.xz *= rotate(T*.3);

    float s = 2.;
    vec3 id = clamp(round(p/s), -2.,2.);

    vec3 q = p;

    for( int x=-1; x<=1; x++ ){
    for( int y=-1; y<=1; y++ ){
    for( int z=-1; z<=1; z++ ){
      vec3 nei = id+vec3(x,y,z);
      nei = clamp(nei, -2.,2.);

      vec3 p1 = id*s;
      vec3 p2 = nei*s;

      // p1 += cos(T)*.5;
      // p2 += sin(T)*.5;

      if(hash31(id+nei+T*.01)<.1){
        float d1 = sdCapsule(q, p1, p2, .04);
        d = min(d, d1);
      }
    }}}


    d = max(0.01, d);
    
    O.rgb += (1.1+sin(vec3(3,2,1)+(id.x+id.y)*.5+p.x+T))/d;
    z += d;

    if(z>50. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}