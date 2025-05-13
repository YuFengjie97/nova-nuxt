#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"
#iChannel1 "file://D:/workspace/nova-nuxt/public/img/noise/good/noise1.jpg"
#define PI 3.1415926




vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d){ return a + b*cos( 6.28318*(c*t+d) ); }


const float DistortStength = 0.2;


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 uv_anime = uv;
  uv_anime.x -= sin(iTime) * 0.01;
  uv_anime.y -= iTime * 0.1;

  vec4 noise_distort = texture(iChannel1, uv) * DistortStength;
  vec4 noise_final = texture(iChannel0, fract(uv_anime + noise_distort.rg));

  float gradient = smoothstep(1., 0., uv.y);
  float n = noise_final.r * gradient;

  // vec3 color = n * mix(vec3(0.,1.,0.), vec3(1.,0.,0.), uv.y);
  vec3 color = sin(vec3(3.,2.,1.) + uv.y) * n;

  O = vec4(color, 1.);

}