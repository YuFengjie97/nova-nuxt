#define T iTime
#define PI 3.141596
#define S smoothstep

// find sphere id trick is from aladin https://www.shadertoy.com/view/wX3GDf
float index = 0.;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
  float d = length(p) - .5;
  return d;
}

// https://iquilezles.org/articles/distfunctions/
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}


const float PHI = 1.61803398875;
vec3 fibonacciSphere(float i, float N) {
  float phi = (1.0 + sqrt(5.0)) * 0.5;              // 黄金比例 ≈ 1.618
  // float goldenAngle = 2.0 * PI * (1.0 - 1.0/phi);   // ≈ 137.5°
  float goldenAngle = sin(T*.07)*2.*PI;

  float z = 1.0 - 2.0 * i / (N - 1.0);      // z 轴分布 [-1, 1]
  float r = sqrt(1.0 - z*z);                // 半径：确保位于单位球面
  float theta = goldenAngle * i;            // 沿纬线均匀分布

  vec3 p = vec3(
      cos(theta) * r,
      sin(theta) * r,
      z
  );  // 得到第 i 个点的球面坐标

  return p;
}

float map(vec3 p, float r, float id){
  float N = 10.;
  float d = 1e5;
  for(float n=0.;n<N-1.;n++){
    vec3 p1 = fibonacciSphere(n,    N);
    vec3 p2 = fibonacciSphere(n+1., N);
    float d1 = sdCapsule(p, p1*r, p2*r, .1*id);
    d = min(d, d1);
  }
  return d;
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


    float s = 2.;
    float D = length(p);
    float id = round(D/s);

    float d1 = map(p, clamp(id,   1.,5.)*s, id);
    float d2 = map(p, clamp(id+1.,1.,5.)*s, id);
    d = min(d, d1);
    d = min(d, d2);


    d = max(0.01, d);
    O.rgb += (1.1+sin(vec3(3,2,1)+id+p.x*.1+T))/d;
    z += d;

    if(z>25. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}