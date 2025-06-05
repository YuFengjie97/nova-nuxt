#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/particle_flow/bufferA.glsl"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/particle_flow/bufferB.glsl"
#define num 10.
#define pix 1./R.y


vec2 hash22(vec2 p) {
  p = fract(p * vec2(5.3983, 5.4427));
  p += dot(p, p + 3.5453123);
  return fract(vec2(
      sin(p.x + p.y * 13.345),
      sin(p.y + p.x * 17.327)
  ) * 95.4337);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R.y;

  float d = 1e6;
  for(float x=0.;x<num;x++){
    for(float y=0.;y<num;y++){
      vec4 particle = texelFetch(iChannel0, ivec2(x,y), 0);
      
      d = min(d, length(uv-particle.xy)-0.01);
    }
  }
  O.rgb += texelFetch(iChannel1, ivec2(I), 0).rgb*0.9;
  O.rgb += smoothstep(0.01,0.009,d);
}