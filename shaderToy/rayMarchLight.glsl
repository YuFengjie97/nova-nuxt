#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"


// 射线步进迭代最大次数
#define MAX_STEPS 100.
// 射线步进判断碰撞的最大距离
#define MAX_DIST 100.
// 射线步进判断碰撞的最小距离
#define SURF_DIST 1e-3

float sdfSphere(vec3 p, float r){
  return length(p) - r;
}


float getDist(vec3 p){
  float sphere = sdfSphere(p-vec3(0.,0.1,0.), 0.1);
  float ground = p.y+0.1;
  return min(sphere, ground);
}

//https://iquilezles.org/articles/normalsSDF/
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


float rayMarch(vec3 ro, vec3 rd){
  float t = 0.;
  for(float i=0.;i<MAX_STEPS;i++){
    vec3 p = ro + rd * t;
    float d = getDist(p);
    t += d;

    if(t>MAX_DIST || d<SURF_DIST) {
      break;
    }
  }
  return t;
}

float getLight(vec3 p){
  vec3 lightPos = vec3(0.,1.,0.);

  lightPos.xz += vec2(sin(iTime), cos(iTime));

  // p-->光源的向量
  vec3 l = normalize(lightPos - p);
  // 表面p点被照射后的法线向量
  vec3 n = getNormal(p);
  // 点积,两向量的夹角值,cos(a)范围是-1到1,限制-1-0范围为0
  float dif = clamp(dot(l,n),0.,1.);

  // 阴影的投射
  // 以p点向光源做射线步进
  // 另外处于ground的p点会被其他物体(这里是ground)遮挡,所以添加法线方向的一个小偏移
  // 这里偏移的量应该比射线步进判断碰撞的最小偏移要稍微大一点
  float d = rayMarch(p+n*SURF_DIST*2., lightPos);
  // 如果d小于该点到光源的距离,则说明中间有障碍物,即为阴影
  if(d<length(lightPos - p)){
    dif = 0.;
  }

  return dif;
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
  col += sin(vec3(.3,.2,.1)+dif);

  fragColor = vec4(col, 1.);
}