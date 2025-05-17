#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define PI 3.141596

float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<8.;i++){
    n += a * texture(iChannel0, p * f).r;
    f *= 2.;
    a *= .5;
  }
  return n;
}

vec3 grid(vec2 p){
  vec3 red = vec3(1.,0.,0.);
  vec3 green = vec3(0.,1.,0.);

  p = fract(p);
  float d = min(abs(p.x), abs(p.y));
  float aa = fwidth(d);
  float s1 = smoothstep(0.02+aa,0.02,d);
  vec3 col = s1 * red;

  p *= 5.;
  p = fract(p);
  float d2 = min(abs(p.x), abs(p.y));
  float aa2 = fwidth(d2);
  float s2 = smoothstep(0.02+aa,0.02,d2);
  col = mix(col, green, s2);

  return col;
}

float getBlenderNoise(vec2 p, int type){
  float n=0.;
  if(type == 0) {
    n += texture(iChannel0, p).r;
    n += texture(iChannel0, p+vec2(0.1)).r;
  }
  if(type == 1) {
    n += fbm(p);
    n += fbm(p+vec2(0.1));
  }

  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float T = iTime * 1e-2;
  O.rgb *= 0.;
  O.a = 1.;

  O.rgb += grid(uv);

  vec2 q = vec2(atan(uv.y, uv.x), log(length(uv)));
  // q.x = cos(2.*q.x);
  float scale = 0.01;
  vec2 offset = vec2(0., T);
  q *= scale;
  q += offset;


  float n = 0.;
  if(iMouse.z > 0.){
    n += getBlenderNoise(q, 0);
  }else{
    n += getBlenderNoise(q, 1);

    // float a = q.x / (PI*2.) + 0.5;
    // float n1 = getBlenderNoise(vec2(a, q.y), 1);
    // float n2 = getBlenderNoise(vec2(mod(a + .001, 1.0), q.y), 1);
    // float blend = smoothstep(.9, 1.0, a);
    // n += mix(n1, n2, a);
  }

  float r = 0.4;
  float d = length(uv);
  float w = 0.4;
  float s = smoothstep(w,0.,abs(d-r));

  s *= n;
  float v = 0.6;
  float feath = 0.1;

  vec3 c = sin(vec3(3.,2.,1.) + pow(s, 3.));

  s = smoothstep(v, v+feath, s);


  O.rgb = mix(O.rgb, c, s);
}