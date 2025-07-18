#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"


#define T iTime
#define PI 3.141596
#define S smoothstep

float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float map(vec3 p){
  // https://www.shadertoy.com/view/3ftGDX
  float d = length(cos(p.xz*0.4)*3. - p.y*0.3)-1.;

  float h = 8.;
  float d1 = p.y + h;
  float d2 = -p.y+h;
  d = min(d, min(d1,d2));

  return d;
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
    p.z += T;

    d = map(p);
    d = max(.01,d);

    O.rgb += (1.1+sin(vec3(3,2,1)+(p.z)*0.2))/d;
    z += d;

    if(z>100. || d<1e-3) break;
  }


  O.rgb = tanh(O.rgb / 1e4);

  vec3 nor = calcNormal(p);
  if(z<100.){
    O.rgb = O.rgb*.5 + boxmap(iChannel0, p*.06, nor, 3.).rgb;
  }
}