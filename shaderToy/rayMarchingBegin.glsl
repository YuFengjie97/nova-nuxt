float sdf_ball(vec3 p) {
  return length(p)-1.;
}

float map(vec3 p){
  float d = sdf_ball(p);
  return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = (fragCoord.xy-iResolution.xy*0.5)/iResolution.y;
  vec3 col = vec3(0.);

  vec3 ro = vec3(0.,0.,-3);
  vec3 rd = normalize(vec3(uv,1.));

  float t = 0.;
  for(int i=0;i<80;i++){
    vec3 p = ro + rd * t;
    float d = map(p);

    t += d;

    if(d<0.001 || t>100.) break;
  }
  col = vec3(t*0.3);
  fragColor = vec4(col,1.);
}