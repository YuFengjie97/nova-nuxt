// 这个buffer根据字符计算sdf

#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText_Sign/bufferA.glsl"
#iChannel1 "file://D:/workspace/nova-nuxt/shaderToy/jfaFireText_Sign/bufferB.glsl"

#define FAR 1e6
#define D distance


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  ivec2 iuv = ivec2(I);
  vec2 uv = I;
  
  bool inChar = texelFetch(iChannel1, iuv, 0).r > 0.;

  /* 
  0位置代表的是你要探测的形状,最近0位置就是边界
  xy存放的是当前位置(外部)像素距离最近0位置的像素坐标
  zw存放的是当前位置(内部)像素距离最近0位置的像素坐标
  初始化:
  如果当前像素位于形状内部,xy为当前像素的uv坐标,即d = D(uv, O.xy),因为O.xy存储上帧距离0最近像素位置,即为uv,d即为0
  如果当前像素位于形状外部,xy为vec2(FAR)

  后续距离比较:
  4个洪水步进方向比较
  O_nei.xy邻居像素存储的距离0最近的像素位置, 当前像素距离0最近的像素位置也是O_nei.xy (我的邻居距离A最近,所以我距离A也是最近的), d = D(uv, O_nei.xy)
  4个邻居,哪个邻居距离0像素位置最近,所以当前像素xy就是那个邻居存储的xy

  zw逻辑相同,不过是在初始化时,将uv vec2(FAR)反转了
  */

  if(iFrame <= 10){
    O.xy = vec2(FAR);
    O.zw = vec2(uv);
    if(inChar) {
      O.xy = vec2(uv);
      O.zw = vec2(FAR);
    }
  }
  else if(iFrame > 200){
    O = texelFetch(iChannel0, iuv, 0);
  }
  else{
    O = texelFetch(iChannel0, iuv, 0);
    // 每次迭代的前进像素数
    int step = 1 << (iFrame % 8);
    
    for(int x=-1;x<=1;x++){
      for(int y=-1;y<=1;y++){
        // 邻居坐标指向自己
        if(x==0 && y == 0) continue;

        ivec2 neigh_c = iuv + ivec2(x,y) * step;
        // 邻居越界(超出分辨率像素尺寸)
        if(neigh_c.x < 0 || neigh_c.y < 0 || neigh_c.x >= int(R.x) || neigh_c.y >= int(R.y)) continue;

        // 邻居中储存的信息
        vec4 neigh = texelFetch(iChannel0, neigh_c, 0);
        // 当前像素位置 到 上帧存储最近0位置距离 < 当前像素位置 到 邻居最近0位置距离 ? 延用上帧 : 用邻居
        O.xy = D(uv, O.xy) < D(uv, neigh.xy) ? O.xy : neigh.xy;
        O.zw = D(uv, O.zw) < D(uv, neigh.zw) ? O.zw : neigh.zw;
      }
    }
  }
}