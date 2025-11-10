// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-4;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float smax( float d1, float d2, float k )
{
    return -smin(-d1,-d2,k);
}



// David Hoskins hash function

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
float voronoi(vec2 uv){
  
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.+T*1.)*.3+.3;
    float d1 = length(nei+pos-uvf);
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
    }else if(d1 < min_d.y){
      min_d.y = d1;
    }
  }
  }

  return min_d.y-min_d.x;
}

vec2 vor;
float map(vec3 p) {
  // vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  // if(iMouse.z>0.){
  //   p.xz*=rotate(m.x);
  //   p.yz*=rotate(m.y);
  // }
  float d = length(p)-5.;
  {
    vec3 q = p;
    float d1 = length(p)-4.;
    d = smax(d, -d1, .2);
  }
  {
    float s = 2.;
    vec3 q = p*s;
    float d1 = dot(cos(q.zxy)/s, sin(q)/s);
    {
      float t = mod(floor(T), 10.);
      float s = hash11(t)+1.;
      float off = s*2.2;
      vec3 q = p*s-off;
      float d2 = dot(cos(q.zxy)/s, sin(q)/s);
      d1 = mix(d1, d2, tanh(sin(T*PI)*3.)*.5+.5);
    }

    d = smax(d1, d, .2);
  }
  
  // 如果让网格噪声附着在transform's物体上,应该写在这里
  // 但是计算normal和raymarch会额外计算
  // vor = voronoi(p.xy*1.6);

  return d;
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );
}

// https://www.shadertoy.com/view/lsKcDD
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = map( pos + h*nor );
        occ += (h-d)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 1.5*occ, 0.0, 1.0 );    
}



// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
              e.xyy*map( pos + e.xyy*eps ) + 
              e.yyx*map( pos + e.yyx*eps ) + 
              e.yxy*map( pos + e.yxy*eps ) + 
              e.xxx*map( pos + e.xxx*eps ) );
}


struct RM{
  bool hit;
  float z;
};

RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    if(d<EPSILON ){

      hit = true;


      break;
    }
    if(z>zMax) break;
    z += d;
  }
  return RM(hit, z);
}


struct Light{
  float amb;
  float diff;
  float spe;
};
Light getLight(vec3 l_dir, vec3 nor, vec3 rd, float amb){
  float diff = max(0., dot(l_dir, nor));
  float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 30.);
  return Light(amb, diff, spe);
}

vec3 Tonemap_ACES(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (x * (a * x + b)) / (x * (c * x + d) + e);
}



float sRGB(float t) { return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-8.);
  if(iMouse.z>0.){
    ro.x += m.x;
    ro.y += m.y;
  }

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 20.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  vec3 col = vec3(0,0,0);
  if(rm.hit) {
    vec3 obj_col = vec3(.1,.5,.4);
    vec3 p = ro + rd * rm.z;
    vec3 nor = calcNormal(p);

    vec3 l_dir = normalize(vec3(0,0,-10)-p);
    
    float fre = pow(max(1.-dot(nor, -rd),0.),2.);
    
    float diff = max(0., dot(l_dir, nor));
    float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 20.);
    col += obj_col * diff*.6 + spe*2. + pow(spe,2.)*10.;

    // https://www.shadertoy.com/view/MtsGWH boxmap
    float vorx = voronoi(p.yz*1.4);
    float vory = voronoi(p.xz*1.4);
    float vorz = voronoi(p.xy*1.4);
    vec3 m = pow( abs(nor), vec3(2.));
	  float vor = (vorx*m.x + vory*m.y + vorz*m.z) / (m.x + m.y + m.z);

    col += pow(.1/(vor), 2.)*vec3(.4,.6,0);
  }

  // col *= exp(-1e-4*rm.z*rm.z);
  // col = pow(col, vec3(1.1545));
  col = Tonemap_ACES(col);
  O.rgb = col;

}