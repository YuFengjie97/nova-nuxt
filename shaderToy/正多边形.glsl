#define PI 3.141596


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float sdNShape(vec2 p, float r, float n){
  float d = -1e4;
  for(float i=0.;i<=n-1.;i++){
    float a = PI*2. / n;
    vec2 p2 = p * rotate(a*i);
    p2.y += r;

    float s = -p2.y;
    d = max(d, s);
  }
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*0.5)/R.y;
  
  float t = sin(iTime) * 0.5 + 0.5;
  
  float d = sdNShape(uv, 0.2, floor(10.*t) + 3.);
  
  
  // iq
  vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
  col *= 1.0 - exp(-6.0*abs(d));
  col *= 0.8 + 0.2*cos(150.0*d);
  col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.005,abs(d)) );

  
  O = vec4(col, 1.);
}