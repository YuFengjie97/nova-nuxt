#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"

float sdfSphere(vec3 p, float r){
  return length(p) - r;
}


float getDist(vec3 p){
  float sphere = sdfSphere(p-vec3(0.,0.1,0.), 0.1);
  float ground = p.y+0.1;
  return min(sphere, ground);
}

vec3 getNormal(vec3 p){
  float d = getDist(p);
  vec2 e = vec2(0.01,0.);
  vec3 n = d - vec3(
    getDist(p-e.xyy),
    getDist(p-e.yxy),
    getDist(p-e.yyx)
  );
  return normalize(n);
}

vec3 getNormal2(vec3 p){
  float eps = 0.01;
  vec2 h = vec2(eps, 0.0);
  return normalize(vec3(
    getDist(p + h.xyy) - getDist(p - h.xyy),
    getDist(p + h.yxy) - getDist(p - h.yxy),
    getDist(p + h.yyx) - getDist(p - h.yyx)
  ));
}

float getLight(vec3 p){
  vec3 lightPos = vec3(0.,1.,0.);

  lightPos.xz += vec2(sin(iTime), cos(iTime));

  vec3 l = normalize(lightPos - p);
  vec3 n = getNormal(p);
  float dif = clamp(dot(l,n),0.,1.);
  return dif;
}

float rayMarch(vec3 ro, vec3 rd){
  float t = 0.;
  for(float i=0.;i<80.;i++){
    vec3 p = ro + rd * t;
    float d = getDist(p);
    t += d;

    if(t>1e2 || d<1e-3) {
      break;
    }
  }
  return t;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = (fragCoord*2. - iResolution.xy)/iResolution.y;
  
  vec3 col = vec3(0.);
  vec3 ro = vec3(0.,.1,-1.);
  vec3 rd = normalize(vec3(uv, 3.));

  float d = rayMarch(ro, rd);

  vec3 p = ro + rd * d;
  // col += d*.5;
  // col = getNormal(p);
  float dif = getLight(p);
  col += dif;

  fragColor = vec4(col, 1.);
}