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

    float n = 5.;
    float s = PI*2. / n;
    float a1 = atan(p.y,p.x);
    float a2 = atan(p.z,p.x);
    
    vec2 id = round(vec2(a1,a2)/s);

    float offset = 6.;

    float range = 2.;
    for(float x=-range;x<=range;x++){
    for(float y=-range;y<=range;y++){
        vec3 q = p;
        vec2 idd = id + vec2(x,y);
        q.xy = rotate(s*idd.x)*q.xy;
        q.xz = rotate(s*idd.y)*q.xz;
        q.x -= offset;

        float d1 = map(q);
        d1 = max(0.01,d1);
        d = min(d, d1);
    }
    }
    
    O.rgb += (1.1+sin(vec3(3,2,1)+id.x+id.y))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}