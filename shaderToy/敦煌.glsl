#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	// vec3 cw = normalize(ta-ro);            // 相机前
	// vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	// vec3 cu = normalize( cross(cw,cp) );   // 相机右
	// vec3 cv = normalize( cross(cu,cw) );   // 相机上
  // return mat3( cu, cv, cw );

  vec3 front = normalize(ta - ro);
  vec3 up = vec3(0,1,0);
  vec3 right = normalize(cross(front, up));
  return mat3(right, up, front);
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-10);
  vec3 rd = setCamera(ro, vec3(0), 0.) * normalize(vec3(uv, 2.));

  float z = .0;

  vec3 col = vec3(0);
  float i = 0.;
  vec3 C = vec3(2.5,1.5,1);
  while(i++<80.){
    vec3 p = ro + rd * z;

  {
    float dist = length(p);

    float f = 1.;
    float a = 1.;
    for(float i=1.;i<4.;i++){
      p += cos(p.zxy*f+T)*a;
      a*=.5;
      f*=2.;
    }
  }

    float d = length(p)-2.;

    d = (d)*.6;

    col += s1(C)/max(0.01, d);

    z += d;
  }

  col = tanh(col / 1e2);

  O.rgb = col;
}