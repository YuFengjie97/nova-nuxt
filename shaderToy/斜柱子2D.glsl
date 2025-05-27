#define T iTime

float hash11(float v) {
  return sin(v + T) * 0.5 + 0.5;
  // return fract(sin(v * 51345.2368 + 442.36 + T*0.1));
}
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

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I) / R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv *= 4.;
  vec2 uvi = floor(uv);

  // grid test
  // float g = smoothstep(0.01,0.,min(abs(uv.x-uvi.x),abs(uv.y-uvi.y)));
  // O.rgb += vec3(1.,0.,0.)*g;

  float up   = abs(uv.y-uvi.y-1.);
  float down = abs(uv.y-uvi.y   );
  float d = min(up,down);
  for(int x=-1;x<2;x++){
    vec2 nei = uvi + vec2(x,0);

    vec2 a = vec2(hash11(nei.x     + nei.y    ), 0);
    vec2 b = vec2(hash11(nei.x*2.1 + nei.y*4.3), 1);
    float l = sdSegment(uv, a + nei, b + nei);
    d = smin(d, l, 0.1);
    // d = min(d, l);
  }

  d = smoothstep(0.05,0.04,d);
  O.rgb += d;
}