#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"


float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<8.;i++){
    n += a * texture(iChannel0, p * f).r;
    f *= 2.;
    a *= 0.5;
  }
  return n;
}

vec3 grid(vec2 p){
  vec3 red = vec3(1.,0.,0.);
  vec3 green = vec3(0.,1.,0.);

  p = fract(p);
  float d = min(abs(p.x), abs(p.y));
  float aa = fwidth(d);
  float s1 = smoothstep(0.01+aa,0.01,d);
  vec3 col = s1 * red;

  p *= 5.;
  p = fract(p);
  float d2 = min(abs(p.x), abs(p.y));
  float aa2 = fwidth(d2);
  float s2 = smoothstep(0.01+aa,0.01,d2);
  col = mix(col, green, s2);

  return col;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float T = iTime * 5e-3;
  O.rgb *= 0.;
  O.a = 1.;

  O.rgb += grid(uv);

  // float n = texture(iChannel0, uv*0.1).r;
  // float r = 0.7;
  // float aa =fwidth(n);
  // float s = smoothstep(r+aa, r, n);
  // O.rgb += s;


  float scale = 0.1;

  float n1 = 0.;
  float n2 = 0.;
  if(uv.x < 0.){
    n1 = texture(iChannel0, uv*scale + T).r;
    n2 = texture(iChannel0, uv*scale - T).r;
  }else{
    n1 = fbm(uv*scale+T);
    n2 = fbm(uv*scale-T);
  }
  float n = n1+n2;

  float r = 0.4;
  float d = length(uv);
  float w = 0.4;
  float s = smoothstep(w,0.,abs(d-r));

  s *= n;
  float nr = 0.6;
  s = smoothstep(nr,nr+0.01,s);



  O.rgb = mix(O.rgb, vec3(1.), s);
}