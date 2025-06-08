#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/雷电/bufferA.glsl"

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I / R;
  O.rgba = texture(iChannel0, uv);
}
