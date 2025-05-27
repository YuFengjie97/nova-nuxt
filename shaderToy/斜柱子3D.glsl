#define T iTime
#define showNor 1

float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

//https://iquilezles.org/articles/distfunctions/
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float hash11(float v){
  return fract(sin(v*1345.154+112.36));
}
vec2 hash22(vec2 v){
  return sin(v * vec2(1,2))*0.5+0.5;
}

float map(vec3 p){
  float h = 10.;
  float d1 = abs(p.y-h);
  float d2 = abs(p.y+h);
  d1 = min(d1,d2);

  vec3 q = p;

  // cos采样,然后-q.y扰动斜率 https://www.shadertoy.com/view/3ftGDX
  d2 = length(cos(q.xz*0.4)*2.-q.y*0.1)-.5;
  // d2 = max(d2, -( p.y+h));
  // d2 = max(d2, -(-p.y+h));

  d1 = smin(d1,d2,.6);

  return d1;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 m = (iMouse.xy*2.-R)/R.y;

  float d = 0.;
  float d_acc = 0.;
  float z = 0.;
  vec3 ro = vec3(0,0,-1);
  vec3 rd = normalize(vec3(uv,1));
  vec3 p;
  for(float i=0.;i<50.;i++){
    p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }
    p.z += T;
    // p.x += sin(T)*5.;

    d = map(p);

    // 透明:https://www.shadertoy.com/view/WfKGRD 
    d = 0.03 + abs(d) * .6;
    d_acc += 1./d;

    z += d;
  }

  vec3 c = (vec3(3,3,1)+p.y*0.1);
  
  // 透明
  O.rgb = tanh(c*d_acc/z/1e2);
  
  // 实心
  //O.rgb = tanh(c*z/1e2);
}