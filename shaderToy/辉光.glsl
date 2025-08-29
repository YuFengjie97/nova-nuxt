// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-6;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec3 p){
    vec3 q = p;

    q += cos(q.zyy*1.);
    q += cos(q.zxx*.5)*1.5;
    q += cos(q.xxy*.25)*2.;

    q.xz *= rotate(q.y*3.+T);

    float D = length(q.xy);
    float s = 2.;
    float id = round(D / s);
    id = clamp(id, 0., 3.);
    D -= id * s;
    float Rc = .5;
    float rc = .3;


    float d = length(vec2(D-Rc, q.z))-rc;

    // d = max(d, 0.);
    d = abs(d) + .1;
    return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 20.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<200.;i++){
    vec3 p = ro + rd * z;

    // if(iMouse.z>0.){
    //   p.xz *= rotate(m.x);
    //   p.yz *= rotate(m.y);
    // }

    float d = map(p);

    col += (1.+sin(vec3(3,2,1)+p.x*.8+p.z*.2))/d;
    
    if(z>zMax) break;

    // z += d;
    // if(d<.1){
    //   float t1 = z - d;
    //   float t2 = z;
    //   for (int i = 0; i < 5; i++) {
    //     float mid = 0.5 * (t1 + t2);
    //     float dm = map(ro + rd * mid);
    //     if (dm < 0.0) t2 = mid; else t1 = mid;
    //   }
    //   z = 0.5 * (t1 + t2); // 更精确的命中点
    //   break;
    // }
    z += d*.02;
  }

  col = tanh(col / 5e2);

  O.rgb = col;
}