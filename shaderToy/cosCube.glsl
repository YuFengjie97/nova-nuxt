// https://www.shadertoy.com/view/WXsXzf,  

struct Info {
  float d;
  vec3 col;
};

vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}


Info getDist(vec3 p){
  Info info;

  p.z += iTime*2.;
  vec3 shape = cos(4.*p+cos(p));
  float d = length(max(shape, shape.yxz * 0.2))/6.;
  info.d = d;
  info.col =  palette(p.y*0.2 + d*2.);
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
    vec3 p = ro + rd * info.d;

    col = info.col;

    col = 1.-exp(-col);
    fragColor = vec4(col,1.0);
}