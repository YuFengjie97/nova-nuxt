//Number of turbulence waves
#define TURB_NUM 10.0
//Turbulence wave amplitude
#define TURB_AMP 0.7
//Turbulence wave speed
#define TURB_SPEED 0.3
//Turbulence frequency
#define TURB_FREQ 2.0
//Turbulence frequency multiplier
#define TURB_EXP 1.4

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
vec3 palette(float t) {
  vec3 a = vec3(0.731, 1.098, 0.192);
  vec3 b = vec3(0.358, 1.090, 0.657);
  vec3 c = vec3(1.077, 0.360, 0.328);
  vec3 d = vec3(0.965, 2.265, 0.837);
  return a + b * cos(6.28318 * (c * t + d));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);

    vec2 p = uv * 2.;
    
    p = turbulence(p);
    
    vec2 i = floor(p);
    vec2 f = fract(p);
    float d1 = abs(p.y-i.y);
    float d2 = abs(p.y-i.y-1.);
    float d3 = abs(p.x-i.x);
    float d4 = abs(p.x-i.x-1.);
    float d = min(min(min(d1,d2),d3),d4);
    float s = smoothstep(0.051,0.05,d);
    
    vec3 c = palette(d+iTime);
    vec3 glow = pow(0.1/d,2.)*c;
    glow = 1.-exp(-glow);
    
    col += glow;

    fragColor = vec4(col,1.0);
}