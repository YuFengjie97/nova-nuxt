
#define T iTime

vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// --- Simplex Noise 主体 ---
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

float fbm(vec2 p){
  float a = .5;
  float n = 0.;
  // mat2 rot = rot2D(1.5);
  // mat2 rot = mat2( 1.6,  1.2, -1.2,  1.6 );

  for(float i=0.;i<4.;i++){
    n += a * noise(p);
    p *= 2.;
    a *= .5;
  }
  return n;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
                s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}

float N(vec2 uv, vec2 dir){
  vec2 scale = vec2(2.);
  vec2 offset = dir * vec2(1.,0.)*(sin(T*0.1)*0.5+0.5)*20.;
  float n = fbm(uv * scale + offset);
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I)/R.y;
  O.rgb *= 0.;
  O.a = 1.;
  uv *= 2.;
  vec2 uvi = floor(uv);
  uv = fract(uv)-0.5;

  float s;
  vec2 boxSize = vec2(0.3, 0.01);
  

  if(uvi.x == 0.) {
    float d = sdBox(uv, boxSize);
    vec2 dir = normalize(vec2(dFdx(d), dFdy(d)));
    float n = N(uv, dir);
    d *= 1.+n;
    s = smoothstep(0.1,0.09,d);
  }
  if(uvi.x == 1.){
    vec3 d = sdgBox(uv, boxSize);
    vec2 g = d.yz;
    vec2 dir = g;
    float n = N(uv, dir);
    float b = d.x * (1.+n);
    // float b = d.x;
    s = smoothstep(0.1,0.09,b);
  }
  

  O.rgb += s * vec3(1.,0.,0.);
}