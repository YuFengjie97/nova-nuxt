// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

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
    vec2 pos = sin(hash22(uvi+nei)*10.+T)*.3+.3;
    float d1 = length(nei+pos-uvf);
    
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
    }else if(d1 < min_d.y){
      min_d.y = d1;
    }
  }
  }

  float edge = min_d.y-min_d.x;
  // return S(.1,0.,edge);
  return edge;
}

float map(vec3 p){
  float d = length(p) - 5.;
  float d1 = d;

  p*=1.3;

  // float t = .5+.5*tanh(sin(T)*3.);
  // float s = mix(1.,2.6,t);
  // p*=s;
  // p.xz *= rotate(p.y*.3+t);

  float d_gyroid = dot(cos(p),sin(p.yzx))-1.1;
  d = max(d, -d_gyroid);
  return d;
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

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 20.;
  float z = .1;
  vec3 p;
  vec3 col = vec3(0);
  bool hit = false;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float d = map(p);
    d = abs(d)*.2+.01;

    float d_voronoi = 0.;
    {
      vec3 q = p * .5;
      float x = voronoi( q.yz );
      float y = voronoi( q.zx );
      float z = voronoi( q.xy );
      float d = (x+y+z)/3.;
      // d_voronoi = pow(.5/d,2.);
      d_voronoi = S(.01,0.,d-.2);
    }

    col += s1(vec3(3,2,1)+d_voronoi*3.) * pow(.15/d,2.);
    
    if(d<EPSILON){
      hit = true;
      col = vec3(1);
      break;
    }
    if(z>zMax) break;
    z += d;

    
  }

  // if(hit){
  //   vec3 n = calcNormal(p);
    
  //   float x = voronoi( p.yz );
  //   float y = voronoi( p.zx );
  //   float z = voronoi( p.xy );
    
  //   vec3 m = pow( abs(n), vec3(1.1) );
  //   float tex = (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
  //   // col += tex*1.;
  // }

  col = tanh(col / 2e3);

  

  O.rgb = col;
  // O.rgb += voronoi(uv);
}