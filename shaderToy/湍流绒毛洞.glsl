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

vec3 path(float v){
  return vec3(cos(v*.2+2.*cos(v*.2))*4.,
              sin(v*.2+2.*sin(v*.2))*4., v);
}

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  float t = T*1.2;

  vec3 ro = path(t);
  vec3 front = normalize(path(t+1.)-ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  vec3 rd = mat3(right, up, front)*normalize(vec3(uv, 1.));
  // vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;
  float d = hash12(uv*40.);

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float f = 1.;
    float a = .26;
    for(float i=0.;i<6.;i++){
      p += sin(p.zxy*f+T*3.)*a;
      f += 1.;
    }

    d += 4.-length(p.xy-path(p.z).xy);
    d = abs(d)*.1 + .005;

    col += (1.1+sin(vec3(3,2,1)+p.x*.1+p.z*.4))/d;
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 4e3);

  O.rgb = col;
}