#define T iTime
#define PI 3.141596
#define S smoothstep


float N = 200.;

//=================================================================================================
// https://www.shadertoy.com/view/lllXz4
// https://dl.acm.org/doi/10.1145/2816795.2818131
//=================================================================================================
vec2 inverseSF( vec3 p ) 
{
    const float kTau = 6.28318530718;
    const float kPhi = (1.0+sqrt(5.0))/2.0;
    // const float kNum = 150.0;
    float kNum = N;

    float k  = max(2.0, floor(log2(kNum*kTau*0.5*sqrt(5.0)*(1.0-p.z*p.z))/log2(kPhi+1.0)));
    float Fk = pow(kPhi, k)/sqrt(5.0);
    vec2  F  = vec2(round(Fk), round(Fk*kPhi)); // |Fk|, |Fk+1|
    
    vec2  ka = 2.0*F/kNum;
    vec2  kb = kTau*(fract((F+1.0)*kPhi)-(kPhi-1.0));    

    mat2 iB = mat2( ka.y, -ka.x, kb.y, -kb.x ) / (ka.y*kb.x - ka.x*kb.y);
    vec2 c = floor(iB*vec2(atan(p.y,p.x),p.z-1.0+1.0/kNum));

    float d = 8.0;
    float j = 0.0;
    vec3 q2;
    for( int s=0; s<4; s++ ) 
    {
        vec2  uv = vec2(s&1,s>>1);
        float id = clamp(dot(F, uv+c),0.0,kNum-1.0); // all quantities are integers
        
        float phi      = kTau*fract(id*kPhi);
        float cosTheta = 1.0 - (2.0*id+1.0)/kNum;
        float sinTheta = sqrt(1.0-cosTheta*cosTheta);
        
        vec3 q = vec3( cos(phi)*sinTheta, sin(phi)*sinTheta, cosTheta );
        // float tmp = dot(q-p, q-p);
        // if( tmp<d ) 
        // {
        //     d = tmp;
        //     j = id;
        // }

        float tmp = length(q-p);
        if(tmp<d){
          d = tmp;
          j = id;
        }
    }
    // return vec2( j, sqrt(d) );
    return vec2( j, d );
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
  float d = length(p) - 5.;
  return d;
}

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


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-15.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;


  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xy *= rotate(T*.5);
    p.xz *= rotate(T*.5);
    p.yz *= rotate(T*.5);

    vec3 nor = (p)/5.;

    vec2 fi = inverseSF(nor);
    float d1 = fi.y-.05;
    d = min(d, max(.01,d1));

    // vec3 pos = fibonacciSphere(fi.x, N);
    // float d1 = length(p-pos)-.1;
    // d = min(d, max(.01,d1));

    O.rgb += (1.1+sin(vec3(3,2,1)+fi.x*.2+T))/d;
    z += d;

    if(z>55. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}