// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep

// Dave_Hoskins https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  float pix = 1./R.y;

  O.rgb *= 0.;
  O.a = 1.;

  float s = .2;
  vec2 id = round(uv/s);
  uv -= id*s;

  float w = 4.*pix;
  float gap = 30.*pix;

  float l_v = abs(uv.x);
  l_v = S(w,w-pix,l_v);
  l_v *= S(gap-2.*pix,gap,abs(uv.y));

  float l_h = abs(uv.y);
  l_h = S(w,w-pix,l_h);
  l_h *= S(gap-2.*pix,gap,abs(uv.x));
  

  float c = length(uv);
  // c = S(10.*pix, 8.*pix, c);
  c = pow(10.*pix/c,2.);

  vec3 col = sin(vec3(3,2,1)+hash12(id+T*4e-4)*10.)*.5+.5;

  O.rgb += l_h + l_v;
  O.rgb = mix(O.rgb, col, c);

}