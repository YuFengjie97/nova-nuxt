/*
    "Turbulent Dark" by @XorDev

    For my tutorial on Turbulence:
    https://mini.gmshaders.com/p/turbulence
    
    
    Simulating proper fluid dynamics can be complicated, limited, and requires a multi-pass setup.

    Sometimes you just want some smoke, fire, or fluid, and you don't want to go through all that trouble.

    This method is very simple! Start with pixel coordinates and scale them down as desired,
    then loop through adding waves, rotating the wave direction and increasing the frequency.
    To animate it, you can add a time offset to the sine wave.
    It also helps to shift each iteration with the iterator "i" to break up visible patterns.

    The resulting coordinates will appear turbulent, and you can use these coordinates in a coloring function.
    
    Smooth, continious equations look best!
*/

//Number of turbulence waves
#define TURB_NUM 8.0
//Turbulence wave amplitude
#define TURB_AMP .3
//Turbulence wave speed
#define TURB_SPEED .5
//Turbulence frequency
#define TURB_FREQ 10.0
//Turbulence frequency multiplier
#define TURB_EXP 1.5

//Apply turbulence to coordinates
vec2 turbulence(vec2 p)
{
    //Turbulence starting scale
    float freq = TURB_FREQ;
    
    //Turbulence rotation matrix
    mat2 rot = mat2(0.6, -0.8, 0.8, 0.6);
    
    //Loop through turbulence octaves
    for(float i=0.0; i<TURB_NUM; i++)
    {
        //Scroll along the rotated y coordinate
        float phase = freq * (p * rot).y + TURB_SPEED*iTime + i;
        //Add a perpendicular sine wave offset
        p += TURB_AMP * rot[0] * sin(phase) / freq;
        
        //Rotate for the next octave
        rot *= mat2(0.6, -0.8, 0.8, 0.6);
        //Scale down for the next octave
        freq *= TURB_EXP;
    }
    
    return p;
}


#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
#define T iTime
#define PI 3.141596
#define S smoothstep

mat2 rotate(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c,-s,s,c);
}

// sdf function is from https://iquilezles.org/articles/distfunctions2d/
float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float sdRhombus( in vec2 p, in vec2 b ) 
{
    p = abs(p);
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*vec2(1.0-h,1.0+h) );
    return d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}
float sdArc( in vec2 p, in vec2 sc, in float ra, float rb )
{
    // sc is the sin/cos of the arc's aperture
    p.x = abs(p.x);
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}


float sdG(vec2 p, float t){
  float d = 1e4;
  // 旋转的刺
  float a = PI*0.3;
  float offset = .5;
  for(float i=0.;i<3.;i+=1.){
    vec2 q = vec2(abs(p.x), p.y);
    q *= rotate(a*i);
    q.y -= offset;
    float d1 = sdRhombus(q, vec2(0.03,0.24*t+0.01));
    d = min(d, d1);
  }

  // 弧
  vec2 q = p * rotate(PI / 2.);
  a = atan(q.y,q.x)/PI;
  float cut = S(0.,.9,abs(a));
  float sca = 2.5;
  float r = 0.02 * smoothstep(0.2,0.6,abs(a));
  float d2 = sdArc(p, vec2(sin(sca), cos(sca)), 0.5, r);
  d = min(d,d2);
  return d;
}


void mainImage( out vec4 O, in vec2 I )
{
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  vec2 p = uv;
  p.y -= T;
  p = turbulence(p);
  p.y += T;

  vec3 c1 = vec3(1,0,0);
  vec3 c2 = vec3(1);
  float t = sin(T*0.5)+.51;

  vec3 c = mix(c1,c2,t);
  vec2 q = mix(p,uv,t);

  float d = sdG(q, t);
  // d = smoothstep(0.,0.2,d);
  d = pow(.01/d,2.);

  O.rgb = c*d;
  // O.rgb = 1.-exp(-O.rgb);
}