#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/particle_flow/bufferB.glsl"

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  // vec2 uv = (I*2.-R)/R.y;

  O = texelFetch(iChannel0, ivec2(I), 0);
}