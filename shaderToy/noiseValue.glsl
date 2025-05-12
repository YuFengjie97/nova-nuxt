#define PI 3.141596


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                * 43758.5453123);
}

float noiseValue(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f*f*(3.0-2.0*f);
    return mix( mix( random( i + vec2(0.0,0.0) ),
                     random( i + vec2(1.0,0.0) ), u.x),
                mix( random( i + vec2(0.0,1.0) ),
                     random( i + vec2(1.0,1.0) ), u.x), u.y);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*0.5)/R.y;
  vec3 col = vec3(0.);

  vec2 p = uv * 20.;

  float noise = noiseValue(p+iTime);
  p *= rotate(noise+iTime);

  // float d = length(uv) - 0.1;
  // float s = smoothstep(0.01,0.,d);;
  // col += s;

  vec2 pf = fract(p);
  float dl = abs(pf.y-0.5);
  // col += sin(vec3(3.,2.,1.) + dl);
  
  float dc = length(pf-0.5);
  float d = min(dl, dc);
  col += sin(vec3(3.,2.,1.) + dc);


  O = vec4(col, 1.);
}