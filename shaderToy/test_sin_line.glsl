#define A(v) mat2(cos(m.v+radians(vec4(0, -90, 90, 0))))  // rotate
#define W(v) length(vec3(0.,p.yz-v(p.x+vec2(0, pi_2)+t)))-lt  // wave
//#define W(v) length(p-vec3(round(p.x*pi)/pi, v(t+p.x), v(t+pi_2+p.x)))-lt  // alt wave
#define P(v) length(p-vec3(0, v(t), v(t+pi_2)))-pt  // point

mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

void mainImage( out vec4 C, in vec2 U )
{
    float lt = .1, // line thickness
          pt = .5, // point thickness
          pi = 3.1416,
          pi2 = pi*2.,
          pi_2 = pi/2.,
          t = iTime*pi,
          s = 1., d = 0., i = d;
    
    vec2 R = iResolution.xy,
         m = (iMouse.xy-.5*R)/R.y*4.;
    
    vec3 o = vec3(0, 0, -7), // cam
         u = normalize(vec3((U-.5*R)/R.y, 1)),
         c = vec3(0), k = c, p;
    
    if (iMouse.z < 1.) m = -vec2(t/20.-pi_2, 0); // move when not clicking
    mat2 v = A(y), h = A(x); // pitch & yaw
    
    for (; i++<50.;) // raymarch
    {
        p = o+u*d;

        //p.xz *= rotate(t*0.1);// 这样rotate可以代替下面两句
        // p.yz *= v;
        // p.xz *= h;


        p.x -= 3.; // slide objects to the right a bit
        // if (p.y < -1.5) p.y = 2./p.y; // reflect into neg y
        k.x = min( max(p.x+lt, W(sin)), P(sin) ); // sine wave
        k.y = min( max(p.x+lt, W(cos)), P(cos) ); // cosine wave
        // s = min(s, min(k.x, k.y)); // blend
        s = min(s, k.y); // blend
       // if (s < .001 || d > 100.) break; // limits
        d += s*0.5;
    }
    
    // add and color scene
    // c = max(cos(d*pi2) - s*sqrt(d) - k, 0.);
    // c.gb += .1;
    // C = vec4(c*.4 + c.brg*.6 + c*c, 1);
    
    vec3 red = vec3(1,0,0);
    vec3 green = vec3(0,1,0);
    vec3 blue = vec3(0,0,1);
    // c = mix(red, green, k.x);
    c = vec3(0);
    float line1 = k.x;
    float line2 = k.y;
    // line1 = cos(line1);
    // line2 = cos(line2);
    // c = mix(c, red,line1);
    c = mix(c, green,line2);
    C = vec4(c, 1);
}