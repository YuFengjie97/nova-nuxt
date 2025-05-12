
float random (vec3 st) {
    return fract(sin(dot(st.xyz,
                          vec3(12.9898,78.233, 41.256)))
                  * 43758.5453123);
}

float noiseValue3D(vec3 st) {
    vec3 i = floor(st);
    vec3 f = fract(st);
    // vec3 u = f*f*(3.0-2.0*f);
    // vec3 u = f * 1.2;

    // this step make noise point became cube
    f *= 2.;
    
    vec3 u = smoothstep(0.,1.,f);
    
    float size = 1.;

    float p1 = random(i);
    float p2 = random(i+vec3(size,0.,0.));
    float n1 = mix(p1,p2,u.x); 
    
    float p3 = random(i+vec3(0.,size,0.));
    float p4 = random(i+vec3(size,size,0.));
    float n2 = mix(p3,p4,u.x);

    float m1 = mix(n1,n2,u.y);

    float p5 = random(i+vec3(0.,0.,size));
    float p6 = random(i+vec3(size,0.,size));
    float n3 = mix(p5, p6, u.x);

    float p7 = random(i+vec3(0.,size,size));
    float p8 = random(i+vec3(size,size,size));
    float n4 = mix(p7, p8, u.x);
    
    float m2 = mix(n3, n4, u.y);

    return mix(m1, m2, u.z);
}
mat2 rot2D(float angle){
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
  p.xy += vec2(cos(iTime), sin(iTime)) * 2.;
  p.z += iTime;

  float d = noiseValue3D(p*0.5);
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I.xy*2.-R.xy)/R.y;
  vec3 col = vec3(0.);


  vec3 ro = vec3(0.,0.,-3.);
  vec3 rd = normalize(vec3(uv,1.));

  float t = 0.;
  for(int i=0;i<80;i++){
    vec3 p = ro + rd * t;
    float d = map(p);

    t += d;

    if(d<0.001 || t>100.) break;
  }

  // col = t * 0.02 * vec3(1.,1.,0.);
  col = sin(vec3(3.,2.,1.) + t*0.12);

  
  O = vec4(col,1.);
}