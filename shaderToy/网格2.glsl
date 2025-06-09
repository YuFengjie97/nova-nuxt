#define T iTime
#define S smoothstep
#define dot2(v) dot(v,v)
#define PI 3.141596


vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2
    const float K2 = 0.211324865; // (3-sqrt(3))/6

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    vec2 o = (a.x > a.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a,a), dot(b,b), dot(c,c)), 0.0);

    vec3 n = h * h * h * h * vec3(
        dot(a, hash(i + 0.0)),
        dot(b, hash(i + o)),
        dot(c, hash(i + 1.0))
    );

    return dot(n, vec3(70.0));
}




// iq article https://iquilezles.org/articles/smin/
float smin( float a, float b, float k )
{
    k *= 1.0;
    float r = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

mat2 rotate(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv *= 4.;
  vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);
  uvf-=0.5;

  vec2 grid = min(vec2(1),fwidth(uv)/abs(uv-round(uv)));
  //O.rgb += max(grid.x,grid.y);


  float d = 1e5;
  float d1 = 1e6;//当前像素距离最近点距离
  float d2 = 1e6;//当前像素距离次近点距离
  for(float x=-1.;x<=1.;x++){
    for(float y=-1.;y<=1.;y++){
      vec2 nei = vec2(x,y);
      
      vec2 feature = random2(nei+uvi)*PI*2.;
      feature = sin(feature+T)*0.25+0.25;
      
      vec2 p = nei-uvf-feature;
      float d_nei = length(p);
      d = min(d,d_nei);
      if(d_nei<d1){
        d2 = d1;
        d1 = d_nei;
      }else if(d_nei<d2){
        d2 = d_nei;
      }
    }
  }
  d = S(0.05,0.,d2-d1);
  O.rgb+=d;  
}