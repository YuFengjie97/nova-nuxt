#define T iTime
#define PI 3.141596

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdBox2d(vec2 p, vec2 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, p.y), 0.);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-4.);
  vec3 rd = normalize(vec3(uv, 1.));
  vec3 p;
  float z;
  float d;

  float t = sin(T)*0.5+0.5;

  for(float i=0.;i<100.;i++){
    p = ro + rd * z;

    p.yz *= rotate(PI/3.);
    // p.xy *= rotate(T/5.);

    float r1 = 1.7, r2=.3;
    vec2 cp = vec2(length(p.xz)-r1, p.y);
    float a = atan(p.x, p.z);
    cp *= rotate(a*3.+T*.5);
    cp.y = abs(cp.y)-.7;
    
    float d = length(cp)-r2;
   	d = sdBox2d(cp, vec2(.1, .3*(sin(4.*a)*.5+.5)))-.1;

    d = abs(d)+0.01;
    // d = max(0., d);
    d *= 0.3;

    O.rgb += (1.1+sin(vec3(3,2,1)+p.x))/d;
    
    z += d; 
    if(z>10. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 2e4);
}