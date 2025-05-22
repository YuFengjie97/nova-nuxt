// 这个buffer根据字符计算sdf

#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText/bufferA.glsl"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText/bufferB.glsl"


vec4 TF(sampler2D smp, vec2 uv){
  return texelFetch(smp, ivec2(uv), 0);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  ivec2 uv = ivec2(I);
  
  bool inChar = texelFetch(iChannel1, uv, 0).r > 0.;

  // 我不知道前(0-2)帧发生了什么,但是似乎这3帧无法触发初始化,vscode shaderToy插件
  if(iFrame <= 10){
    O.a = inChar ? 0. : 1e10;
  }
  else if(iFrame > 300){
    O.a = texelFetch(iChannel0, uv, 0).a;
  }
  else{
    float dMin = texelFetch(iChannel0, uv, 0).a;
    int step = 1 << iFrame % 8;

    for(int x=-1;x<=1;x++){
      for(int y=-1;y<=1;y++){
        if(x==0 && y==0) continue;
        ivec2 target = ivec2(uv) + step * ivec2(x,y);
        if(target.x < 0 || target.y < 0 || target.x >= int(R.x) || target.y >= int(R.y)) continue;

        float targetPixD = texelFetch(iChannel0, target, 0).a; 
        if(targetPixD < 1e10){
          vec2 D = vec2(target - uv);
          float d = length(D) + targetPixD;
          dMin = min(dMin, d);
        }
      }
    }
    O.a = dMin;
  }
}