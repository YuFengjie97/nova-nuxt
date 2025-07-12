#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep


float map(vec3 p) {
  float d = length(p)-4.;
  return d;
}


// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps )+ 
					  e.yyx*map( pos + e.yyx*eps )+ 
					  e.yxy*map( pos + e.yxy*eps )+ 
					  e.xxx*map( pos + e.xxx*eps ));
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

  float z;
  float d = 1e10;
  vec3 p;

  for(float i =0.;i<100.;i++){
    p = ro + rd * z;
    p.xz *= rotate(T*.5);
    p.xy *= rotate(T*.5);
    p.yz *= rotate(T*.5);

    d = map(p);
    // d = max(0.01, d);
    z+=d;
    if(z>10. || d<1e-3) break;
  }

  vec3 nor = calcNormal(p);
  if(z<10.){
    O.rgb = boxmap(iChannel0, p*.1, nor, 3.).rgb;
  }
}