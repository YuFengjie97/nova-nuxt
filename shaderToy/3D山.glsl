#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"

#define PI 3.141596

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float f = 1.;
  float a = 1.;
  float n = 0.;
  for(float i=0.;i<8.;i++){
    n += noise(p*f)/f;
    f *= 1.5;
    a *= .9;
  }
  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float T = iTime;
  vec2 m = (iMouse.xy*2.-R)/R.y * 0.5;

  O.rgb *= 0.;
  O.a = 1.;


  vec3 ro = vec3(0.,4.,0.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = 0.;
  float d = 0.;

  for(float i=0.;i<50.;i++){
    vec3 p = z * rd + ro;

    if(iMouse.z > 0.) {
      p.xz *= rotate(-m.x * PI * 2.);
      p.yz *= rotate(-m.y * PI * 2.);
    }

    p.z += T*0.4;
    vec3 q = p;
    // q.z = sin(q.z) * 0.5 + 0.5;
    // q.x = sin(q.x) * 0.5 + 0.5;

    // float h = noise(q.zx * .1) * 4.5;
    float h = fbm(q.zx * .1) * 1.5;

    float d = q.y - h;
    d = max(d * 0.3, 0.01);
    z += d;
    O.rgb += (sin(vec3(3.,2.,1.) + p.z) + 1.1) / (d*0.4);

    // if(z > 1e4 || d < 1e-2) break;
  }
  O.rgb = tanh(O.rgb * 2e-4);
}