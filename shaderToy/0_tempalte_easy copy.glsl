#define T iTime
#define PI 3.141596
#define S smoothstep
#define dot2(v) dot(v,v)

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 hash33(vec3 p){
  vec3 seed = vec3(30,23,12);
  return abs(cos(p * seed + vec3(2,1,3)+T*3.)/seed);
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

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;



  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xy *= rotate(T*.3);
    p.xz *= rotate(T*.3);

    float s = 4.;
    vec3 id = round(p/s);
    
    // vec3  o = sign(p-s*id);
    // for( int x=0; x<2; x++ ){
    // for( int y=0; y<2; y++ ){
    // for( int z=0; z<2; z++ ){

    //   vec3 idd = id + vec3(x,y,z)*o;
    //   vec3 q = p-s*clamp(idd,-1.,1.);
      
    //   float d1 = length(q)-.5;
    //   d = min(d, d1);
    // }
    // }
    // }
    // d = max(0.01, d);

    vec3 q = p - s*clamp(id,-1.,1.);
    vec3 pos = vec3(0.);
    float d1 = length(q-pos)-.5;
    // d = min(d, d1);

    for( int x=-1; x<=1; x++ ){
    for( int y=-1; y<=1; y++ ){
    for( int z=-1; z<=1; z++ ){
      vec3 nei = id + vec3(x,y,z);
      // vec3 q = p - s*idd;
      float d1 = sdCapsule(p, id, nei, .3);
      d = min(d, d1);
    }}}

    d = max(0.01, d);
    
    O.rgb += (1.1+sin(vec3(3,2,1)+(id.x+id.y)))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 2e4);

}