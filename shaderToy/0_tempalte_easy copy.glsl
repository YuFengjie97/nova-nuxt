#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep


vec4 map(vec3 p) {
  vec3 col = vec3(0);
  float d = 0.;
  return vec4(col, d);
}


// https://iquilezles.org/articles/normalsSDF/
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


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    p.xz *= rotate(T);
    p.xy *= rotate(T);

    vec3 q = p;
    float d1 = length(q)-2.;
    d = min(d, d1);
    d = max(0.01,d);

    O.rgb += (1.1+sin(vec3(.5,.5,.5)+(p.z)*0.2+10.*texture(iChannel0, p.xy*.2).rgb))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e4);

}