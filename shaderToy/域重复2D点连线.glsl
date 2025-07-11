#define T iTime
#define PI 3.141596
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash21(vec2 p) {
    p = fract(p * vec2(3.34, 5.21));
    p += dot(p, p + 5.32);
    return fract(sin(dot(p, vec2(2.98, 7.23))) * 4.3);
}
float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  float s = 10.;
  vec2 p = uv*s;
  vec2 id = floor(p);
  vec2 p2 = fract(p);
  float d = abs(length(p2-.5)-.1);

  vec3 col = vec3(0.);

  for(float x=-1.;x<=1.;x++){
  for(float y=-1.;y<=1.;y++){
    vec2 nei = id+vec2(x,y);
    vec2 pp = abs(id+nei);
    float n = hash21(pp+T*1e-5);
    // float n = hash21(pp);
    if(n<.2){
      float d1 = sdSegment(p, id+.5, nei+.5)-.02;
      d = min(d, d1);

      col = (sin(vec3(3,2,1)+n*20.)*.5+.5);
    }
  }}

  d = S(0.04,0.,d);
  // d = pow(.1/d, 2.);
  O.rgb += d*col;
}