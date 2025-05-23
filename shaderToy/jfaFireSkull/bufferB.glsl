#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireSkull/bufferA.glsl"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireSkull/bufferB.glsl"
#iKeyboard

#define FAR 1e6
#define D distance


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  ivec2 iuv = ivec2(I);
  vec2 uv = I;
  
  bool inShape = texelFetch(iChannel0, iuv, 0).r > 0.5;

  if(iFrame <= 10 
    || texelFetch(iChannel1,ivec2(0,0),0).w != R.x * R.y
    // || texelFetch(iChannel3,ivec2(32,0),0).x > 0.
    || isKeyReleased(32)                             
    ){
    
    if (iuv.x == 0 && iuv.y == 0){
      O = vec4(0, 0, 0, R.x * R.y);
      return;
    }

    O.xy = vec2(FAR);
    O.zw = vec2(uv);
    if(inShape) {
      O.xy = vec2(uv);
      O.zw = vec2(FAR);
    }
  }
  else{
    O = texelFetch(iChannel1, iuv, 0);

    if(iuv.x == 0 && iuv.y == 0) return;
    
    int step = 1 << (iFrame % 8);
    
    for(int x=-1;x<=1;x++){
      for(int y=-1;y<=1;y++){
        if(x==0 && y == 0) continue;

        ivec2 neigh_c = iuv + ivec2(x,y) * step;
        if(neigh_c.x < 0 || neigh_c.y < 0 || neigh_c.x >= int(R.x) || neigh_c.y >= int(R.y)) continue;

        vec4 neigh = texelFetch(iChannel1, neigh_c, 0);

        if(neigh_c.x == 0 && neigh_c.y == 0) continue;


        O.xy = D(uv, O.xy) < D(uv, neigh.xy) ? O.xy : neigh.xy;
        O.zw = D(uv, O.zw) < D(uv, neigh.zw) ? O.zw : neigh.zw;
      }
    }
  }
}