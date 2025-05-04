#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/good/perlin.jpg"
#iChannel1 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/color.png"

#define PI 3.141596

float sdfCircle(vec2 p, float r) {
  return length(p) - r;
}
float sdMoon(vec2 p, float d, float ra, float rb )
{
    p.y = abs(p.y);
    float a = (ra*ra - rb*rb + d*d)/(2.0*d);
    float b = sqrt(max(ra*ra-a*a,0.0));
    if( d*(p.x*b-p.y*a) > d*d*max(b-p.y,0.0) )
          return length(p-vec2(a,b));
    return max( (length(p          )-ra),
               -(length(p-vec2(d,0))-rb));
}

float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float sdRhombus( in vec2 p, in vec2 b ) 
{
    p = abs(p);
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*vec2(1.0-h,1.0+h) );
    return d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}

vec2 twistH(vec2 p){
  float offset = sin(p.x) * sin(4.*p.x)/10.;
  p.y += offset;
  return p;
}

mat2 rotate(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c,-s,s,c);
}
float getStab(vec2 p, float offset){
    vec3 n = texture(iChannel0, p*vec2(.7,10.)+offset+iTime*0.4).rgb;
    float d = sdRhombus(p, vec2(0.15,0.02));
    float aa = fwidth(d);
    
    float d2 = n.r-0.5;
    d = max(d, d2);
    float shape = smoothstep(aa,-aa,d);
    return shape;
}

float getMoon(vec2 p){
  p *= rotate(PI * 0.5);
  float d = sdMoon(p, 0.05,.3,0.26);
  float aa = fwidth(d);
  float br = 0.03;
  float angle = atan(p.y,p.x)+PI;
  float len = length(p);
  vec3 n = texture(iChannel0, vec2(angle/PI, len)*vec2(1.5,10.)+vec2(0., -iTime*0.8)).rgb;
  float d2 = n.r - 0.5;
  d = max(d,d2);
  
  float shape = smoothstep(0., -aa,d);
  return shape;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-iResolution.xy * 0.5)/iResolution.y;
    vec3 col = vec3(0.);
    

    float s1 = getStab((uv-vec2(0.,0.25))*rotate(PI*0.5), 0.1);
    float s2 = getStab((uv-vec2(-0.25,0.15))*rotate(PI*0.23), 0.2);
    float s3 = getStab((uv-vec2(-0.3,-0.1))*rotate(PI*(-0.1)), 0.3);
    float s4 = getStab((uv-vec2(0.25,0.15))*rotate(PI*0.75), 0.4);
    float s5 = getStab((uv-vec2(0.3,-0.1))*rotate(PI*1.1), 0.5);

    float c = getMoon(uv);
    float shape = s1 + s2 + s3 + s4 + s5 + c;
    col += shape;

    //float dist = min(c,min(s5,min(s4,min(s3,min(s1,s2)))));
    //vec3 glow = pow(0.1/dist, 2.) * vec3(1.);
    //glow = 1.-exp(-glow);
    //col += glow;

    fragColor = vec4(col, 1.);
}