// https://www.shadertoy.com/view/WXcGRB  详细在评论里

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

  float s = 6.;
  vec3 id = round(q.xyz/s);
  q.xyz -= clamp(id, -1., 1.)*s;

  float d = length(q)-2.;
  vec3 col = vec3(0,0,0);
  if(d<.1){
    col = 1.1+sin(vec3(3,2,1)+(p.x)*4.);
  }
  d = clamp(d, 0.001, 100.);
  return vec4(col, d*0.4);
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

  vec3 ro = vec3(0,0,-20);
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