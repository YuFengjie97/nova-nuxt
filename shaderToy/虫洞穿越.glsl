//https://www.shadertoy.com/view/t3VSWm

// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 path(float v){
  return vec3(cos(v*.2+sin(v*.1 ))*4.,
              sin(v*.2+cos(v*.1))*4., v);
}

// https://www.shadertoy.com/view/4djSRW
vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);
}
float hash13(vec3 p3){
  return fract(dot(p3, cos(p3.yzx)));
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i=0.;i<5.;i++){
    n += amp*abs(dot(cos(p*fre), vec3(.06)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = iMouse.xy/R * 5.;

  O.rgb *= 0.;
  O.a = 1.;

  float t = T*(sin(T*4e-4+cos(T*4e-4))*4.+4.);
  vec3 ro = path(t);
  vec3 ta = path(t+1.);
  vec3 front = normalize(ta - ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  vec3 rd = mat3(right, up, front) * normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    vec3 q = p;

    float s = 4.;
    vec3 id = round(q/s);
    q -= id*s;
    vec3  o = sign(p-s*id); // neighbor offset direction
    float d = 1e20;
    for( int x=0; x<2; x++ )
    for( int y=0; y<2; y++ )
    for( int z=0; z<2; z++ )
    {
        vec3 rid = id + vec3(x,y,z)*o;
        vec3 r = p - s*rid;
        r += hash33(rid)*(s/2.)-(s/4.);
        float d1 = length(r) - .02 + hash13(rid+T*1e-3)*.1;
        d = min( d, d1);
    }
    d = max(0., d);

    float d1 = length(p.xy-path(p.z).xy)-3.;
    d1 = abs(d1)+.01;
    d1 += fbm(p*2.+t);
    d = min(d, d1);
    d = d * (1.-hash12(uv.xy*100.+T)*.2);

    float k = sin(p.z+p.x*.5+p.y*.3)*.5+.5;

    col += k * (1.1+sin(vec3(3,2,1)+p.x+p.z+hash13(id)))/d;

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e2);

  O.rgb = col;
}