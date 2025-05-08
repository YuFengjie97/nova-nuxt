struct Info {
  float d;
  vec3 col;
};



Info getDist(vec3 p){
  Info info;

  p.z += iTime*.8;
  
  
  
  vec3 shape = cos(4.*p);
  
  
  // very important!!!!   the cube base-------the magic part--------
  //float d = length(max(shape, shape.zxy * 0.02));
  float d = length(max(shape, 0.));
  //d /= sqrt(3.);
  d /= 6.;
  //--------------------------------------------------
  
  
  
  info.d = d;
  info.col =  sin(vec3(3.,2.,1.)+p.y);
  
  
  return info;
}

Info rayMarch(vec3 ro, vec3 rd){
  Info infoBase;
  float t = 0.;
  for(float i=0.;i<80.;i++){
    vec3 p = ro + rd * t;
    Info info = getDist(p);
    infoBase.col = info.col;
    t += info.d;

    if(t>1e2 || info.d<1e-3) {
      break;
    }
  }
  infoBase.d = t;
  return infoBase;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    
    vec3 col = vec3(0.);
    vec3 ro = vec3(0.,0.,-3.);
    vec3 rd = normalize(vec3(uv, 1.));
    Info info = rayMarch(ro, rd);

    col = info.col;

    //col = 1.-exp(-col);
    fragColor = vec4(col,1.0);
}