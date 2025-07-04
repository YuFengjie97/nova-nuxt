#define T iTime
#define PI 3.141596
#define S smoothstep


vec4 map(vec3 p) {
  vec3 col = vec3(0);
  float d = 0.;
  return vec4(col, d);
}


// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ).w + 
					  e.yyx*map( pos + e.yyx*eps ).w + 
					  e.yxy*map( pos + e.yxy*eps ).w + 
					  e.xxx*map( pos + e.xxx*eps ).w );
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;


  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0,0,-40.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z;
  float d = 1e10;

  float r = 6.;

  for(float i =0.;i<300.;i++){
    vec3 p = ro + rd * z;
    p.xz *= rotate(p.y*.2);

    float amp = 1.1;
    float freq = 1.2;
    for(float x=1.;x<5.;x++){
      p.xyz += amp*sin(p.zxy*freq+T*4.);
      freq *= 1.5;
      amp *= .5;
    }


    for(float x = -1.;x<=1.;x++){
      if(x==0.) continue;
      vec3 q = p;
      float d1 = length(q.xz-10.*x)-2.;
      d1 = abs(d1*.1)+.1;
      // d1 = clamp(0.001, 4., abs(d1*.6)+0.1);
      O.rgb += (1.1+sin(vec3(3,2,1)*x+.1*(p.z+p.y)*.4))/d1;
      d = min(d, d1);
    }

    z += d;
    if(z>60. || d<1e-3) break;
  }

  O.rgb = tanh(O.rgb / 1e3);

  // vec2 d1 = abs(uv) - vec2(0.5,0.2);
  // float s = length(max(d1,0.0));
  // O.rgb += s;
}