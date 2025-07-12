#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/域重复2D点连线.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep


float map(vec3 p) {
  float d1 = length(p)-4.;

  p = abs(p)-vec3(4.);
  float d2 = max(p.x,max(p.y,p.z));
  
  float d = mix(d1, d2, sin(T)*.5+.5);
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

// https://www.shadertoy.com/view/ws3Bzf
vec4 biplanar( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
    // grab coord derivatives for texturing
    vec3 dpdx = dFdx(p);
    vec3 dpdy = dFdy(p);
    n = abs(n);

    // determine major axis (in x; yz are following axis)
    ivec3 ma = (n.x>n.y && n.x>n.z) ? ivec3(0,1,2) :
               (n.y>n.z)            ? ivec3(1,2,0) :
                                      ivec3(2,0,1) ;
    // determine minor axis (in x; yz are following axis)
    ivec3 mi = (n.x<n.y && n.x<n.z) ? ivec3(0,1,2) :
               (n.y<n.z)            ? ivec3(1,2,0) :
                                      ivec3(2,0,1) ;
    // determine median axis (in x;  yz are following axis)
    ivec3 me = ivec3(3) - mi - ma;
    
    // project+fetch
    vec4 x = textureGrad( sam, vec2(   p[ma.y],   p[ma.z]), 
                               vec2(dpdx[ma.y],dpdx[ma.z]), 
                               vec2(dpdy[ma.y],dpdy[ma.z]) );
    vec4 y = textureGrad( sam, vec2(   p[me.y],   p[me.z]), 
                               vec2(dpdx[me.y],dpdx[me.z]),
                               vec2(dpdy[me.y],dpdy[me.z]) );
    
    // blend factors
    vec2 w = vec2(n[ma.x],n[me.x]);
    // make local support
    w = clamp( (w-0.5773)/(1.0-0.5773), 0.0, 1.0 );
    // shape transition
    w = pow( w, vec2(k/8.0) );
    // blend and return
    return (x*w.x + y*w.y) / (w.x + w.y);
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
    d = max(0.01, d);

    z+=d;
    O.rgb += (1.1+sin(vec3(3,2,1)+p.x*.5))/d;
    if(z>10. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb/1e4);

  vec3 nor = calcNormal(p);
  if(z<10.){
    O.rgb = mix(O.rgb, boxmap(iChannel0, p*.16, nor, 3.).rgb,.5);
    // O.rgb = mix(O.rgb, biplanar(iChannel0, p*.1, nor, 3.).rgb,.5);
  }
}