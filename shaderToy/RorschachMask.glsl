#define PI 3.141596
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/color.png"

float sdfCircle(vec2 p, float r){
  return length(p) - r;
}

float sdHexagram( in vec2 p, in float r )
{
    const vec4 k = vec4(-0.5,0.8660254038,0.5773502692,1.7320508076);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= 2.0*min(dot(k.yx,p),0.0)*k.yx;
    p -= vec2(clamp(p.x,r*k.z,r*k.w),r);
    return length(p)*sign(p.y);
}

mat2 rotate(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c,-s,s,c);
}

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

vec3 random(float seed){
  vec3 n = texture(iChannel0, vec2(seed)+iTime*0.005).rgb - 0.5;
  return n;
}

vec3 palette(float t) {
  vec3 a = vec3(0.731, 1.098, 0.192);
  vec3 b = vec3(0.358, 1.090, 0.657);
  vec3 c = vec3(1.077, 0.360, 0.328);
  vec3 d = vec3(0.965, 2.265, 0.837);
  return a + b * cos(6.28318 * (c * t + d));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = (fragCoord.xy * 2. - iResolution.xy)/iResolution.y;
  vec3 col = vec3(0.);

  uv *= 2.;

  uv.x = abs(uv.x);
  
  vec2 p = turbulence(uv);
  //vec2 p = uv;

  float d = 1.;

  for(float i=0.;i<10.;i++) {
    float seed = (i+1./i)*0.1;

    vec3 n = random(seed);
    vec2 pos = n.xy*4.;
    pos.x = abs(pos.x);
    float r = n.z + 0.2;
    float d1 = sdfCircle(p - pos, r);
    d = min(d, d1);
  }
    
  col += d;  

  //col += pow(.5/d,.4)*palette(d);
  //col = 1.-exp(-col);

  fragColor = vec4(col, 1.);
}