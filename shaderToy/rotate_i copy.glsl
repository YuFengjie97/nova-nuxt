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

float sdBoxFrame( vec3 p, vec3 b, float e ){
      p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float smax( float d1, float d2, float k )
{
    return -smin(-d1,-d2,k);
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

  mat2 mx = rotate(T*.5);
  mat2 my = rotate(T*.5);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }


  vec3 col = vec3(0);
  vec3 p;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;

    // p = mix(p, vec3(fbm(p*2.+vec3(0,T*10.,0))), vec3(.1));

    // float d = length(p) - 5.;
    float d = sdBox(p, vec3(4.));

    float d1;
    {
      vec3 q = p;
      // q.xy *= rotate(T+i*3.);
      // q.xz *= rotate(T+i*2.);
      // q.yz *= rotate(T+i*1.);
      // d1 = q.y+fbm(q*.2+T)*1.;
      // d1 = length(sin(q*.1))-.1;
      d1 = sdBoxFrame(cos(q), vec3(.9),.1);
      // d1 = length(sin(q.xz*.08))-.1;
      // d1 = max(0., d1);
      d1 = abs(d1)*.6+.001;
      d1 = max(d, d1);
    }
    d = abs(d)*.3+.01;
    d = min(d, d1);

    // d = max(EPSILON,d);

    
    col += s1(vec3(3,2,1)+dot(p,vec3(.4)))/d;
    if(d<EPSILON || z>zMax) break;
    z += d;
  }
  col = tanh(col / 2e3);



  O.rgb = col;
}