#iChannel0 "file://D:/workspace/nova-nuxt/public/img/skull/2.jpg"


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy; // 屏幕分辨率
  vec2 uv = (I - 0.5 * R) / R.y; // 将画布中心归一化为 (0,0)，保持纵轴一致

  float scale = 2.0; // 缩放系数，可调节图像大小
  vec2 imageSize = vec2(1.0, 1.0); // 你的图片实际尺寸（宽高）,正方形可为1,1
  float aspect = imageSize.x / imageSize.y;

  uv.x /= aspect; // 调整横向坐标，让图像不被压扁或拉伸

  vec2 texUV = uv * scale + 0.5; // 从中心坐标转换回纹理空间 (0~1)

  // 纹理采样
  vec4 color = texture(iChannel0, texUV);

  // 防止越界采样：强制只有在 0~1 范围内时才显示
  color *= step(0.0, texUV.x) * step(texUV.x, 1.0) * step(0.0, texUV.y) * step(texUV.y, 1.0);

  O = vec4(color.rgb, 1.0);
}
