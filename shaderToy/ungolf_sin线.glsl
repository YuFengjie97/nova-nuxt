void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  float T=.3*iTime;

  vec3 ro = vec3(0,0,1);
  vec3 rd = normalize(vec3(I-.5*R, R.y));

  float d = 0.;
  float D = 1e6;
  float z = 0.;
  vec3 p;
  vec4 P;
  vec4 U = vec4(0,1,2,3);
  vec4 o = vec4(0);

  // 普通rayMarch
  for(float i=0.;i<77.;i++){

    p = rd*z;
    d = 4.;
    p.z-=4.;

    // 这个for循环就是map函数
    for(float j=4.;j<9.;j++){

      D = 2./(j-3.)+p.y/3.;
      P = vec4(p,p.z);
      P.x -= .3*sin(p.y+T);
      P.xz *= mat2(cos(j-T+p.y+11.*U.xywx));
      P = abs(P);
      D = min(max(P.z,P.x-D)+2E-2,
              length(P.xz-D*U.yx)
            );
      P = 1.2+sin(j+U.xyzy+z);
      o += P.w*P/D;
      d = min(d, D);
    }
    
    z+=.6*d+1E-3;
  }
  O = tanh(o/1E3);
}