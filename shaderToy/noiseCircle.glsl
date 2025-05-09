#define pi 3.14159

float h21(vec2 a) {
    return fract(sin(dot(a.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// smoothly mixes between two consecutive hashes
float rand(float val, vec2 ipos) {
    float a = h21(ipos / 1e2 + floor(val)),
          b = h21(ipos / 1e2 + ceil(val)),
          m = smoothstep(0., 1., fract(val));
    return mix(a, b, m);
}

void mainImage( out vec4 o, vec2 u )
{
    vec2 R = iResolution.xy;
    u = (u-.5*R)/R.y;
                  
    float t = iTime;             
                 
    float scale = 4.;
    
    vec2 uv2 = u * scale;
    
     
    vec2 i = floor(uv2),
         f = fract(uv2) - 0.5;
         
    
    float a = 0.,
          seed0 = 10. * length(u) + t,
          rand0 = rand(seed0, vec2(6.6));
    
    float k = 10. * length(f) * rand0,
          seed1 = 2.5 * rand0 * sin(k) + t,
          rand1 = rand(seed1, vec2(4.4));
    
    
    float d = length(f),
          s = smoothstep(1., 0., d);
    
    o.rgb = s * (1. + sin((4.*rand1 + d + vec3(3, 2., 1))));
}