//https://www.shadertoy.com/view/tXVSRG


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

vec3 hash33( uvec3 x )
{
    const uint k = 1103515245U;
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    x = ((x>>8U)^x.yzx)*k;
    
    return vec3(x)*(1.0/float(0xffffffffU));
}
vec2 hash21(float p)
{
	vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

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
  vec2 m = (iMouse.xy-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.+T*10.);
  vec3 rd = normalize(vec3(uv, 1.));

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
    float id = round(q.z/s);
    q.z -= id*s;

    // 每层随机个数范围
    float n_min = 1.;
    float n_max = 10.;
    // 每层随机位置范围
    float r = 20.;

    float n = hash11(id)*(n_max-n_min)+n_min;
    float d = 1e4;
    for(float i=0.;i<n;i++){
      vec2 pos = hash21(id*33.24+i*85.49).xy*r - r*.5;
      float d1 = length(q-vec3(pos, 0.)) - .02;
      d = min(d, d1);
    }

    d = max(0., d);

    
    col += (1.1+sin(vec3(3,2,1)+p.x+p.z))/d;
    
    if(d<EPSILON || z>zMax) break;
    z += d*.3;
  }

  col = tanh(col / 1e3);

  O.rgb = col;
}