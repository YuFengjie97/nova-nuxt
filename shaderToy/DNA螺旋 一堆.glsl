#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"


#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float map(vec3 p, out vec3 col, vec2 idd){
  float d;
  p.xz *= rotate(p.y*.1+T);
  vec3 q = p, q2 = p;

  // 中间的横向线
  float s = 1.;
  float id = round(q.y/s);
  q.y -= s*id;
  float d1 = length(q.yz)-.2;

  // 圆柱来限制范围
  float r = (sin(idd.x)*.5+.5)*idd.x+.5;
  // float r = 2.;
  float d2 = length(p.xz)-r;
  d = max(d1, d2);
  d = max(0.01, d);
  col += (1.1+sin(vec3(3,2,1)+id*.2+idd.x))/d;

  // 两侧竖直的线
  q2.x = abs(q2.x);
  float r3 = r*.1;
  float d3 = length(q2.xz-vec2(r+r3,0))-r3;
  d3 = max(0.01, d3*.8);
  d = min(d, d3);
  col += (1.1+sin(vec3(3,2,1)+q2.y*.2+idd.x))/d3;

  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-40.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;


  for(float i =0.;i<200.;i++){
    vec3 p = ro + rd * z;
    p.xz *= rotate(T*.2+p.y*.1);

    float s = 6.;
    vec2 id = round(p.xz/s);
    vec2  o = sign(p.xz-s*id);

    for(float x=0.;x<2.;x++){
      for(float y=0.;y<2.;y++){
        vec2 rid = id + vec2(x,y)*o;
        p.xz -= s*clamp(rid, 0., 1.);

        float d1 = map(p, O.rgb, rid);
        d = min(d, d1*.4);
      }
    }

    z += d;
    if(z>130. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb/1e4);
}