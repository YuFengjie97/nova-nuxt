// 详细查看评论 https://www.shadertoy.com/view/WXcGRB
// 其实原因不是因为raymarch的不安全步进导致进入了物体内部,
// 而是我的域重复写错了
// 但是abs(d)在其他地方是相当有用的
// d*scale 应是最后的调整手段,因为会增加for loop

#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec4 map(vec3 p){
  vec3 q = p.xyz;

  // wrong version
  //float n = 6.;
  //vec3 id = round(q.xyz/n)*n;
  //id = clamp(id, -10., 10.);
  //q.xyz -= id;
  
  
  // correct version
  float n = 6.;
  vec3 id = round(q.xyz/n);
  id = clamp(id,-2.,2.)*n;
  q.xyz -= id;
  
  
  float r = 0.1 + (sin(id.x+id.y+id.z + T)*0.5+0.5) * 2.;
  

  float d = length(q)-r;
  vec3 col = vec3(0,0,0);
  if(d<.1){
    col = 1.1+sin(vec3(3,2,1)+(id.x+id.y+id.z)*4.+p.x*.5);
    //col = 1.1+sin(vec3(3,2,1)+(p.x)*4.);
    // col = vec3(1,0,0);
  }
  return vec4(col, d);
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
                      e.xyy*map( pos + e.xyy*eps ).w + 
					  e.yyx*map( pos + e.yyx*eps ).w + 
					  e.yxy*map( pos + e.yxy*eps ).w + 
					  e.xxx*map( pos + e.xxx*eps ).w );
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-30);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d;
  vec4 U;
  vec3 p;

  for(float i =0.;i<100.;i++){
    p = ro + rd * z;

    p.xy *= rotate(T*0.3);
    p.xz *= rotate(T*0.3);

    float d = map(p).w;

    z += d;

    if(z > 1e2 || abs(d) < 1e-3) break;
  }

    vec3 nor = calcNormal(p);
    vec3 amb = vec3(0);
    float diff = dot(amb, nor)*0.5+0.5;
    vec4 M = map(p);
    O.rgb = M.rgb * diff;
}