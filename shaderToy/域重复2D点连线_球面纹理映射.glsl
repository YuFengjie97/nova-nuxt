#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep

// https://iquilezles.org/articles/distfunctions/
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
  float d = length(p)-4.;
  // float d = sdBox(p, vec3(3.));
  return d;
}


// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy ) + 
                      e.yyx*map( pos + e.yyx ) + 
                      e.yxy*map( pos + e.yxy ) + 
                      e.xxx*map( pos + e.xxx ) );
}
// https://www.shadertoy.com/view/MtsGWH
vec4 boxmap( in sampler2D s, in vec3 p, in vec3 n, in float k )
{
    // project+fetch
	vec4 x = texture( s, p.yz );
	vec4 y = texture( s, p.zx );
	vec4 z = texture( s, p.xy );
    
    // and blend
  vec3 m = pow( abs(n), vec3(k) );
	return (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
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

  float z = 0.;
  float zMax = 20.;

  for(float i =0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    if(d<1e-3) break;
    z+=d;
    if(z>zMax) break;
  }

  if(z<zMax){
    vec3 p = ro+rd*z;

    p.xz *= rotate(T*.3);
    p.yz *= rotate(T*.3);
    vec3 nor = calcNormal(p, 0.001);

    float diff = clamp(dot(nor, vec3(0,0,-1)),0.,1.);
    O.rgb = vec3(1,0,0)*diff;
    O.rgb = mix(O.rgb, boxmap(iChannel0, fract(p*.2), nor, 8.).rgb, .7);
  }
}