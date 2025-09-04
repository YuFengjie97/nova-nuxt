// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)

const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - k*0.5*(1.0+h-sqrt(1.0-h*(h-2.0)));
}
float smax(float a, float b, float k) {
    return -smin(-a, -b, k);
}



// https://iquilezles.org/articles/palettes/
vec3 palette( in float t)
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
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
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    // p.z += T;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float sz = 2.; // z方向重复距离
    float idz = round((p.z)/sz);
    p.z -= idz * sz;

    float r = .4;
    float RA = sz*2.; // 主圆柱体半径
    vec3 offset = vec3(RA,0,0);

    vec3 q = p;
    
    float a = atan(p.y,p.x);
    float s = TAU / 20.;  // 角度重复次数
    float id = round(a/s);
    q.xy = rotate(s*id)*q.xy;
    q -= offset;


    float d = length(q) - r;
    d = abs(d)*.2 + 0.01;


    // vec3 c = sin(vec3(3,2,1)+p.x*.4+idz)+1.;
    vec3 c = palette(sin(idz*3.+id*PI*.2));
    col += c * pow(.1/d,2.);
    


    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e3);

  O.rgb = col;
}