#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p, float r1, float r2){
  float d = length(vec2(length(p.xy)-r1, p.z))-r2;
  return d;
}



void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb = vec3(0);
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= rotate(T);

    vec3 q = p;
    float s = 1.;
    float dc = length(q.xyz);
    float id = clamp(round(dc/s),1.,4.);
    float r = dc-id*s;
    float theta = acos(q.z/r);
    float phi = atan(q.y,q.x);
    float x1 = r * sin(theta) * cos(phi);
    float y1 = r * sin(theta) * sin(phi);
    float z1 = r * cos(theta);
    q -= vec3(x1,y1,z1);
    d = map(q, .5, .1);
    d = max(0.01,d);


    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}