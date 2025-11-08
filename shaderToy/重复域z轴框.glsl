// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<2.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}


float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.z += T*10.;

    // p = mix(p, vec3(fbm(p*2.+vec3(0,T*10.,0))), vec3(.1));

    float size = 6.;
    float id = floor(p.z/size);
    p.z -= (id + .5) * size;


    float t = T*1.4+id*.2;
    float ang = hash11(id+floor(t));
    float ang2 = hash11(id+floor(t+1.));
    ang = mix(ang, ang2, S(.5,1.,fract(t)));

    p.xy *= rotate(ang*2.);

    float n = abs(dot(cos(p.zxy+T), sin(p)));
    p = mix(p, vec3(n), tanh(s1(T*10.+ang)*3.)*.2);
    float d = sdBoxFrame(p, vec3(4, 4, 1.), .2);
    d += n * 1.;

    d = abs(d)*.2 + .01;
    // d = max(EPSILON,d);

    
    col += s1(vec3(3,2,1)+id)*pow(.3/d,2.);
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }
  col = tanh(col / 2e2);

  O.rgb = col;
}