#define white vec3(1.)
#define black vec3(0.)
#define red vec3(1.,0.,0.)
#define PI 3.141596

float sdfCircle(vec2 p, float r){
  return length(p)-r;
}

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float sdfFiveAngle(vec2 p, float r){
  float d = -10.;
  for(float i=0.;i<=4.;i++){
    float a = PI*2. / 5.;
    vec2 p2 = p * rotate(a*i);
    p2.y += r;

    float s = -p2.y;
    d = max(d, s);
  }
  return d;
}


vec4 ringWithBorder(vec2 p){
  float w = 0.02;
  float c = abs(sdfCircle(p, 0.2));
  float aa = 0.003;
  float s = smoothstep(w+aa,w-aa,c);
  float s2 = smoothstep(w*2.+aa,w*2.-aa,c);
  
  float shape = max(s, s2);
  vec3 shapeColor = s * white + s2 * black;
  return vec4(shapeColor, shape);
}

vec3 magician(vec2 p){
  vec4 r1 = ringWithBorder(p+vec2(-0.1,0.));
  vec4 r2 = ringWithBorder(p+vec2( 0.1,0.));
  return mix(r1.rgb , r2.rgb , p.y > 0. ? r2.a : (1.-r1.a));
}

vec3 highPriestess(vec2 p){
  float d = abs(sdfCircle(p, 0.3));
  float aa = fwidth(d);
  float w = 0.03;
  return smoothstep(w+aa,w-aa,d) * white;
}

vec3 empress(vec2 p){
  vec3 col = black;
  float r = 0.2;
  

  float R = 0.24;
  float gap = 0.02;

  float outer = sdfFiveAngle(p, 1e-10);
  float aa = fwidth(outer);
  float outerShape = smoothstep(R-gap, R-gap-aa, outer);
  col += outerShape * white;

  for(float i=0.;i<16.;i++) {
    float a = mod(i, 4.) <= 1. ? 0. : PI;
    vec3 c = mod(i,2.) == 0.? black : white;
    float r = mod(i,2.) == 0. ? cos(PI/5.) * (R+gap) : R - gap;
    R = r;

    vec2 p2 = p * rotate(a);
    float d = sdfFiveAngle(p2, 1e-10);
    float aa = fwidth(d);
    
    float s = smoothstep(r, r-aa, d);
    col = mix(col, c, s);
  }

  return col;
}

float sdfRect(vec2 p, float r){
  p = abs(p);
  p -= r;
  float d = max(p.x, p.y);
  return d;
}

vec3 emperor(vec2 p) {
  vec3 col = black;

  float d = sdfRect(p, 1e-10);
  float aa = fwidth(d);

  float rect1 = smoothstep(0.2, 0.2-aa, d);
  col = mix(col, white, rect1);
  
  float rect2 = smoothstep(0.18, 0.18-aa, d);
  col = mix(col, black, rect2);

  float rect3 = smoothstep(0.04, 0.04-aa, d);
  col = mix(col, white, rect3);
  return col;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*0.5)/R.y;
  vec3 col = vec3(0.);
  uv *= vec2(2.);
  vec2 uvi = floor(uv);
  vec2 uvf = fract(uv);
  uvf -= 0.5;
  float i = uvi.y * 5.+uvi.x;
  if(uvi.x==0. && uvi.y==0.){
    vec3 d = magician(uvf);
    col = d;
  }
  if(uvi.x==0. && uvi.y==-1.){
    vec3 d = highPriestess(uvf);
    col = d;
  }
  if(uvi.x==-1. && uvi.y==0.){
    col = empress(uvf);
  }
  if(uvi.x==-1. && uvi.y==-1.){
    col = emperor(uvf);
  }

  O = vec4(col, 1.);
}