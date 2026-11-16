#iChannel0 "./volumeA.glsl"

// col() access RGBA channels (color and density)
// map() access UVWX channels (mapping)

#define T(p,i,j,k)  texture(iChannel0,.5*clamp(.5+.5*(p),0.,1.)+.5*vec3(i,j,k)).r
#define col(p) ( a = abs(p), max(a.x,max(a.y,a.z))>1. ? vec4(0) \
                    : vec4( T(p,0,0,0), T(p,1,0,0), T(p,0,1,0), T(p,1,1,0))) // get volume RGBA or 0
#define map(p) ( a = abs(p), max(a.x,max(a.y,a.z))>1. ? vec4(0) \
                    : vec4( T(p,0,0,1), T(p,1,0,1), T(p,0,1,1), T(p,1,1,1))) // get volume UVWX or 0


void mainVolume( out vec4 O, vec3 p ) {  
    O = texelFetch(iChannel0,ivec3(p.xy,p.z-1.),0.);
    p = mod(p,64.);
    if (p.z>1.) return;                                // only slice 1
    p /= 64.;          
    if (iFrame < 1) O*=0.;                             // init  
    
    O.x = 0.;
    float q = length(p.xy - vec2(0.5));
    float t = 0.25 + sin(iTime*2.3)*0.25 - sin(iTime*4.3) * (0.1 + sin(iTime)*0.1);
    
    if(abs(q - t)< 0.01) O.x = 1.;
  
    // p.xy range:  0...1 
    // if(p.x < 0.01) O.x = 1.;
    // if(p.x > 0.98) O.x = 1.;
    // if(p.y < 0.01) O.x = 1.;
    // if(p.y > 0.98) O.x = 1.;
}
