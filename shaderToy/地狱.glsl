// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/shaderToy/texture1.jpg"

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
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float smax( float d1, float d2, float k )
{
    return -smin(-d1,-d2,k);
}

float map(vec3 p){
  float d = -abs(p.y) + 4.;
  {
    vec3 q = p;
    q.xz += cos(q.xz*2.)*.2;
    float s = 4.;
    vec2 id = floor(q.xz / s);
    q.xz = (q.xz-id*s)/s - .5;
    float r = abs(dot(cos(id), vec2(.2))) * .3 + .1;
    float d1 = length(q.xz) - r;
    d1 += abs(dot(cos(p), vec3(.2,.8,1.5)))*.1;
    d = smin(d, d1, .1);
  }

  return d;
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

vec4 fire(vec3 p) {
  // float d = cos(p.y*2.);
  float d = dot(cos(p.xz),vec2(.13));
  return (vec4(7,2,1,1) * d * d );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec4 col = vec4(0);

  vec3 ro = vec3(0,0,T);
  vec3 rd = normalize(vec3(uv, 1.));

  vec3 p;
  float i = 0.;
  float z = 0.1;
  while(i++<80.){
    p = ro + rd * z;
    float d = map(p);
    z += d;
    col += fire(p);
  }
  // p = POS;

  // 普通法线
  vec3 nor = calcNormal(p);

  // col = vec3(1,0,0);

  // bump扰动后的法线
  vec3 nor2 = texBump(iChannel0, p*.1, nor, .04);
  col.rgb *= tex3D(iChannel0, p*.3, nor2).rgb;

  vec3 l_dir = normalize(ro+vec3(0,0,0)-p);
  float diff = max(.1, dot(l_dir, nor2));

  // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
  float spe = pow(max(0., dot(normalize(l_dir-rd), nor2)), 30.);
  
  col = col * diff + spe;

  col *= exp(-1e-2*z*z);
  // col = tanh(col / 20.);
  O = col;
}