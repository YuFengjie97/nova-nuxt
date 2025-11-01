// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
#define pix (1./iResolution.y)

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec3 C = vec3(3,2,1);
float map(vec2 p){
  float t = tanh(sin(T)*3.);

  float d = 1e4;
  for(float i =0.;i<1.;i+=1./6.){
    p = abs(p);
    p -= vec2(.1,.2)*(t+2.);
    p *= rotate(i*TAU+t);

    float d1 = sdBox(p, vec2(i+.1));
    d1 = S(0.,0.,abs(d1));
    d = min(d,d1);
  }
  C += dot(p, vec2(4.));

  return d;
}

vec3 calcNormal(vec2 p){
  vec2 eps = vec2(0.0001, 0.);
  return normalize(vec3(
    map(p+eps.xy)-map(p-eps.xy),
    map(p+eps.yx)-map(p-eps.yx),
    0.001
  ));
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;
  uv*=2.4;

  vec3 nor = calcNormal(uv*.3);
  vec3 col = s1(C)*.7;
  uv = abs(uv);
  vec3 l_pos = vec3(cos(T),sin(T),.6)+.5;
  vec3 l_dir = normalize(l_pos-vec3(uv,0));
  float diff = max(0.,dot(l_dir, nor));
  float spe = pow(max(0., dot(reflect(-l_dir,nor), vec3(0,0,1))),30.);
  col = col*.5 + diff*col + spe*.2;

  // col = 1.-exp(-2.7*col);
  O.rgb = col;
}