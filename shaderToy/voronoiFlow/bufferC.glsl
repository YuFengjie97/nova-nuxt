// 拖尾显示

#iChannel0 "./bufferB.glsl"
#iChannel1 "./bufferC.glsl"

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;
  float pix = 1. / R.y;

  O.rgb *= 0.;

  int POOL = 20;
  float d = 0.;
  for(int x=0;x<POOL;x++){
    for(int y=0;y<POOL;y++){
      vec4 particle = texelFetch(iChannel0, ivec2(x,y), 0);
      vec2 pos = particle.xy;
      float life = particle.z;
      float seed = particle.w;

      float d1 = length(uv-pos);
      d1 = smoothstep(3.*pix,0.,d1)*smoothstep(0.,.1,life)*smoothstep(1.,.9,life);

      vec3 col = sin(vec3(3,2,1)+seed*10.)*.5+.5;
      O.rgb += col*d1;
    }
  }
  vec3 lf = texture(iChannel1, I/R).rgb;
  O.rgb += lf*.95;

}