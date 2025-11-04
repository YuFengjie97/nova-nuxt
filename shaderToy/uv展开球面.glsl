// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-2;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

vec2 sphericalToUV(vec3 p) {
    p = normalize(p);
    return vec2(
        0.5 + atan(p.z, p.x) / (2.0 * PI),
        0.5 - asin(p.y) / PI
    );
}
vec2 sphericalToEquirectangular(vec3 p) {
    p = normalize(p);
    
    // 经度 (longitude): -π 到 π → 0 到 1
    float longitude = atan(p.z, p.x);
    float u = longitude / (2.0 * PI) + 0.5;
    
    // 纬度 (latitude): -π/2 到 π/2 → 0 到 1  
    float latitude = asin(p.y);
    float v = latitude / PI + 0.5;
    
    return vec2(u, v);
}


// David Hoskins hash function
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

// https://iquilezles.org/articles/voronoilines/
/*
oA 最小距离特征点
oB 次小距离特征点
*/
vec2 voronoi(vec2 uv, out vec2 oA, out vec2 oB){
  
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  // x分量代表当前像素距离特征点的最小距离,y代表次小距离
  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+T)*.3+.3;
    float d1 = length(nei+pos-uvf);
    /*
    距离小于最小距离,
    次小距离更新为现在的"最小距离"
    最小距离更新

    距离小于次小距离,
    次小距离更新
    */
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
      oA = pos;
    }else if(d1 < min_d.y){
      min_d.y = d1;
      oB = pos;
    }
  }
  }

  return min_d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  vec3 p;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float d = length(p) - 4.;
    
    // col += (1.1+sin(vec3(3,2,1)+p.x));
    
    if(d<EPSILON){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }

  if(hit) {
    // vec2 uv = sphericalToEquirectangular(p);
    vec2 uv = sphericalToUV(p);
    uv *= 4.;

    vec2 a = vec2(0);
    vec2 b = vec2(0);
    vec2 d = voronoi(sin(uv*PI), a, b);
    float edge = d.y - d.x;  // 减去值配合发光半径,营造出立体感

    vec3 c = s1(vec3(3,2,1)+a.x*20.);

    col += edge*c*2.+pow(.1/(edge-.5),2.)*c;
  }

  O.rgb = col;
}