float sdfSphere(vec3 p, float r) {
  return length(p)-r;
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 rot3D(vec3 p, vec3 axis, float angle){
  return mix(dot(axis,p) * axis,p,cos(angle)) + cross(axis,p) * sin(angle);
}

mat2 rot2D(float angle){
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c,-s,s,c);
}

float smin( float a, float b, float k )
{
    k *= 6.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*h*k*(1.0/6.0);
}
float map(vec3 p){
  vec3 sphere_pos = vec3(sin(iTime*0.5)*3.,0.,0.);
  float sphere = sdfSphere(p-sphere_pos, .5);

  vec3 p2 = p;
  p2.y -= iTime*0.4;
  p2 = fract(p2)-0.5;
  float box = sdBox(p2, vec3(.15));

  float ground = p.y+0.75;

  float d = smin(ground,smin(sphere, box, 0.1), 0.1);
  return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = (fragCoord.xy*2.-iResolution.xy)/iResolution.y;
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.y;
  vec3 col = vec3(0.);

  vec3 ro = vec3(0.,0.,-3.);
  vec3 rd = normalize(vec3(uv,1.));


  float t = 0.;
  for(int i=0;i<80;i++){
    vec3 p = ro + rd * t;
    float d = map(p);

    t += d;

    if(t<0.001 || t>100.) break;
  }

  //float s = pow(0.5/(t*0.2), 1.);
  //vec3 glow = s * vec3(1.,0.,0.);
  //col += 1.-exp(-glow);
  
  col = vec3(t*0.05);
  fragColor = vec4(col,1.);
}