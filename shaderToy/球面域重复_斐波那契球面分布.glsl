#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
  float d = length(p) - .5;
  return d;
}

const float PHI = 1.61803398875;
vec3 fibonacciSphere(float i, float N) {
  float phi = (1.0 + sqrt(5.0)) * 0.5;              // 黄金比例 ≈ 1.618
  float goldenAngle = 2.0 * PI * (1.0 - 1.0/phi);   // ≈ 137.5°

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

    d = length(p)-3.;
    d = max(0.01,abs(d)-.1);

    float r = 5.;
    float N = 30.;
    for(float n=1.;n<N;n++){
      vec3 pos = fibonacciSphere(n, N)*r;
      float d1 = length(p-pos)-.5;
      d1 = max(0.01,d1);
      d = min(d, d1);
    }
    
    
    O.rgb += (1.1+sin(vec3(3,2,1)+p.x))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}