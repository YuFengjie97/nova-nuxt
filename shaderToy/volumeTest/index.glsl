// thanks to FabriceNeyret2
#define T(p,i,j,k)  texture(iChannel0,.5*clamp(.5+.5*(p),0.,1.)+.5*vec3(i,j,k)).r
#define col(p) ( a = abs(p), max(a.x,max(a.y,a.z))>1. ? vec4(0) \
                    : vec4( T(p,0,0,0), T(p,1,0,0), T(p,0,1,0), T(p,1,1,0))) // get volume RGBA or 0
#define map(p) ( a = abs(p), max(a.x,max(a.y,a.z))>1. ? vec4(0) \
                    : vec4( T(p,0,0,1), T(p,1,0,1), T(p,0,1,1), T(p,1,1,1))) // get volume UVWX or 0


// reusing the 8-channels base https://shadertoy.com/view/f3KSWw

#define rot(a)  mat2( cos(a+vec4(0,11,33,0)) )               // rotation                  
#define keyToggle(c)  ( texelFetch(iChannel3,ivec2(c,2),0).x > 0.)

vec2 box(vec3 P, vec3 D) // box intersection from https://www.shadertoy.com/view/sXKXRy
{
    vec3 t0 = (-1. - P) / D, t1 = (1. - P) / D, // 1. = box radius
       m = min(t0, t1), M = max(t0, t1);
    return vec2( max(max(m.x, m.y), m.z)
               , min(min(M.x, M.y), M.z));
}

void mainImage(out vec4 O, vec2 U) {    
    float t = iTime;
    vec3  R = iResolution, a,
          M = length(iMouse.xy) > 10. ? iMouse.xyz/R -.5: vec3(.6,.05,0),//vec3(8,0,4)/1e2*cos(0.+vec3(0,11,0)),
          D = normalize(vec3( U+U, -3.5*R.y ) - R ),         // ray direction
          p = vec3(0,0,5); 
    O*=0.;
    p.yz *= rot( 6.*M.y), D.yz *= rot( 6.*M.y);              // camera move 
    p.xz *= rot( 6.*M.x), D.xz *= rot( 6.*M.x);
                          
    vec2 B = box(p,D);                                       // clamp to box
    float l = B.x, T = 1., dl = 2./128., i;                  // render
    vec4 C ;
    for ( p += l*D; l < B.y && i < 500.; i++,  p += D*dl, l+=dl )
     // d = map(p).r, 
        C = col(p),                                          // color
        a = abs(p)-1.,
        max(a.x,max(a.y,a.z)) > dl ? C                       // box
        : C = max(C,vec4( 2.*smoothstep(1.5*dl,0.,min(length(a.xy),min(length(a.yz),length(a.zx)))))),
        O += T * C*C.a * dl * 8.,                            // why *16. ?
        T *= exp(-8.*C.a*dl);  
        
    if keyToggle(32) O = vec4(1.-T);
}