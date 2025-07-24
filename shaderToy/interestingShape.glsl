#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep



mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec4 map(vec3 p) {
  p.xz *= rotate(T*.5);

  float d = length(p)- 4.;

  float n = 0.;
  float amp = 2.;
  float fre = 1.;
  for(float i=1.;i<5.;i++){
    n += amp*abs(dot(cos(p*fre),vec3(.7)));
    // n += amp*abs(dot(cos(p*fre)/fre,vec3(.7)));
    fre *= 1.+1.*(sin(T*.5)*.5+.5);
    amp *= .5;
  }
  d += n;

  vec3 col = sin(vec3(3,2,1)+p.x*.4)*.5+.5;
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

float rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).w*.2;
    if(d<1e-3 || z>zMax) break;
    z += d;
  }

  return z;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 30.;

  float z = rayMarch(ro, rd, 0.1, zMax);

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;
    vec4 M = map(p);
    vec3 nor = calcNormal(p);

    col = M.rgb;
    // col = boxmap(iChannel0, fract(p*.1), nor, 7.).rgb;

    vec3 l_pos = vec3(0);
    float diff = clamp(dot(normalize(l_pos-p),nor),0.,1.);
    col += diff;

    float spe = clamp(dot(reflect(normalize(p-l_pos), nor), -rd),0.,1.);
    col += spe;
  }

  col *= exp(-1e-3*z*z*z);
  // col = pow(col, vec3(.5));
  O.rgb = col;

}