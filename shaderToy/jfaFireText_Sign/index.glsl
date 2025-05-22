#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText_Sign/bufferB.glsl"


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I;
  O.rgb *= 0.;
  O.a = 1.;

  // vec4 D = texture(iChannel1, uv/R.y);
  vec4 D = texelFetch(iChannel1, ivec2(uv), 0);   // 必须使用texelFetch,用归一化的uv坐标来展示jfa计算后的图像,会导致撕裂,挤压,不连续

  float d = (length(uv-D.xy) - length(uv-D.zw)) / R.y;
  vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
  col *= 1.0 - exp(-6.0*abs(d));
	col *= 0.8 + 0.2*cos(150.0*d);
  col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.005,abs(d)) );
  

  O.rgb = col;
}
