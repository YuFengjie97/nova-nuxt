// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture5.jpg"

/*
    This code is from @Shane's "Offworld Storage Facility",
    which can be found here:

        https://www.shadertoy.com/view/DsVfRV

*/

// Tri-Planar blending function: Based on an old Nvidia writeup:
// GPU Gems 3 - Ryan Geiss: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
vec3 tex3D(sampler2D tex, in vec3 p, in vec3 n){    
    
    // Ryan Geiss effectively multiplies the first line by 7. It took me a while to realize that 
    // it's largely redundant, due to the division process that follows. I'd never noticed 
    // on account of the fact that I'm not in the habit of questioning stuff written by 
    // Ryan Geiss. :)
    n = max(n*n - .2, .001); // max(abs(n), 0.001), etc.
    n /= dot(n, vec3(1)); 
    //n /= length(n); 
    
    // Texure samples. One for each plane.
    vec3 tx = texture(tex, p.yz).xyz;
    vec3 ty = texture(tex, p.zx).xyz;
    vec3 tz = texture(tex, p.xy).xyz;
    
    // Multiply each texture plane by its normal dominance factor.... or however you wish
    // to describe it. For instance, if the normal faces up or down, the "ty" texture 
    // sample, represnting the XZ plane, will be used, which makes sense.
    
    // Textures are stored in sRGB (I think), so you have to convert them to linear space 
    // (squaring is a rough approximation) prior to working with them... or something like 
    // that. :) Once the final color value is gamma corrected, you should see correct 
    // looking colors.
    return mat3(tx*tx, ty*ty, tz*tz)*n; 
}
// Texture bump mapping. Four tri-planar lookups, or 12 texture lookups in total. 
// I tried to make it as concise as possible. Whether that translates to speed, 
// or not, I couldn't say.
vec3 texBump( sampler2D tx, in vec3 p, in vec3 n, float bf){
   
    const vec2 e = vec2(.001, 0);
    
    // Three gradient vectors rolled into a matrix, constructed with offset greyscale 
    // texture values.    
    mat3 m = mat3(tex3D(tx, p - e.xyy, n), tex3D(tx, p - e.yxy, n), 
                  tex3D(tx, p - e.yyx, n));
    
    vec3 g = vec3(.299, .587, .114)*m; // Converting to greyscale.
    g = (g - dot(tex3D(tx,  p , n), vec3(.299, .587, .114)))/e.x; 
    
    // Adjusting the tangent vector so that it's perpendicular to the normal -- Thanks 
    // to EvilRyu for reminding me why we perform this step. It's been a while, but I 
    // vaguely recall that it's some kind of orthogonal space fix using the Gram-Schmidt 
    // process. However, all you need to know is that it works. :)
    g -= n*dot(n, g);
                      
    return normalize( n + g*bf ); // Bumped normal. "bf" - bump factor.
	
} 

// @Shane
// Commutative smooth minimum function. Provided by Tomkh, and taken 
// from Alex Evans's (aka Statix) talk: 
// http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf
// Credited to Dave Smith @media molecule.
float smin(float a, float b, float k){

   float f = max(0., 1. - abs(b - a)/k);
   return min(a, b) - k*.25*f*f;
}

// 2D vector version.
vec2 smin(vec2 a, vec2 b, float k){

   vec2 f = max(vec2(0), 1. - abs(b - a)/k);
   return min(a, b) - k*.25*f*f;
}

// Commutative smooth maximum function. Provided by Tomkh, and taken 
// from Alex Evans's (aka Statix) talk: 
// http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf
// Credited to Dave Smith @media molecule.
float smax(float a, float b, float k){
    
   float f = max(0., 1. - abs(b - a)/k);
   return max(a, b) + k*.25*f*f;
}



#define T iTime
#define PI 3.1415926
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-3;


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


vec3 col = vec3(0,0,0);

float map(vec3 p) {
  // p.xz *= rotate(T);
  float height = 4.;
  float d = abs(abs(p.y)-4.);
  {
    vec3 q = p;
    q.xz += cos(q.zx*1.)*1.;
    q.xz += cos(q.zx*2.)*.5;
    float s = 2.;
    vec2 id = floor(q.xz / s);
    q.xz = (q.xz - id*s)/s - .5;

    vec3 pos = vec3(0,fract(-T*.4)*12. - 6.,0);
    float d1 = length(q-pos) - .3;
    d = smin(d, d1, .4);
  }
  return d;
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );
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

struct RM{
  bool hit;
  float z;
};


RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
    col += vec3(7,2,1)/10.;
  }
  return RM(hit, z);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  if(rm.hit) {
    vec3 p = ro + rd * rm.z;

    // 普通法线
    vec3 nor = calcNormal(p);

    // col = tex3D(iChannel0, p*.1, nor).rgb;
    // col = vec3(1,0,0);

    // bump扰动后的法线
    nor = texBump(iChannel0, p*.1, nor, .03);

    vec3 l_dir = normalize(ro-p);
    float diff = max(.1, dot(l_dir, nor));

    float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    // float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 30.);
    
    col = col * diff + spe;

    // col *= calcAO(p, nor);
  }

  col *= exp(-1e-2*rm.z*rm.z);
  col = pow(col, vec3(.4545));
  O.rgb = col;

}