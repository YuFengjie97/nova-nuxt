#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/color.png"


void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
  vec3 col = vec3(0.);

  vec3 ro = vec3(0.,0.,-2.);
  vec3 rd = normalize(vec3(uv, .0)-ro);

  float t = 0.;
  for(float i=0.;i<80.;i++){
    vec3 p = rd * t;
    p.z += iTime;

    float d = texture(iChannel0, p.yz).r;

    if(t>1e2 || d<1e-3) break;
    t += d;
  }
  col = vec3(t*0.01);

  fragColor = vec4(col, 1.);
}