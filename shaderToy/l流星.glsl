#define T iTime
#define S smoothstep
#define PI 3.141596
#define s1(v) (sin(v)*.5+.5)

const float EPSILON = 1e-6;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy+p3.yzz)*p3.zyx);
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
  vec3 p = vec3(0);
  for(float i=0.;i<10.;i++){
    p = ro + rd * z;
    

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    // float s = 2.;
    // vec2 id = round(p.yz/s);
    // id = clamp(id, -1., 1.);
    // p.yz -= id*s;

    float d = 1e4;

    float num = 2.;
    for(float x=-num;x<=num;x++){
    for(float y=-num;y<=num;y++){

    vec2 id = vec2(x,y);

    vec3 n = hash32(id);
    vec3 pos_off = (n-.5)*10.;
    float speed = n.x * .1 + .1;

    float len = speed*20.;
    float r = 4./len;
    vec3 q = p - pos_off;
    q.x += (fract(T*speed)-.5)*100.;
    float d1 = length(q-vec3(clamp(q.x,0.,len),0,0));
    d = min(d, d1);

    vec3 c = s1(vec3(2.8,2,1)+id.x+id.y*2.+s1(q.x-T*speed*40.)*2.);
    r *= S(len,0.,q.x);
    // float r = clamp(exp(-p.x+2.),0.,4.);
    col += pow(r/d1,3.)*c;

    }
    }

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e2);

  O.rgb = col;
}