#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/最终幻想仙人掌/texture.glsl"

#define T iTime
#define PI 3.141596
#define S smoothstep

// https://iquilezles.org/articles/smin/
float smin( float a, float b)
{
    float k = .02;
    k *= 1.0/(1.0-sqrt(0.5));
    return max(k,min(a,b)) -
           length(max(k-vec2(a,b),0.0));
}

// https://iquilezles.org/articles/functions/
float sinc( float x, float k )
{
    float a = PI*(k*x-1.0);
    return sin(a)/a;
}


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p, float v){
  float res = 0.;
  for(float i =1.;i<5.;i++){
    res += abs(dot(cos(p*i*10.+i*.32), vec3(v)))/i;
  }
  return res;
}

// https://iquilezles.org/articles/distfunctions/
float sdVerticalCapsule( vec3 p, float h, float r )
{
  p.y -= clamp( p.y, 0.0, h );
  return length( p ) - r;
}

float sdSphere(vec3 p, float r){
  return length(p) - r;
}

vec4 map(vec3 p) {
  float d = 1e4;
  vec3 col = vec3(0,.8,0);

  // plane
  float d_plane;
  {
    vec3 q = p;
    d_plane = (q.y+4.5);
    if(d_plane<.01){
      col = vec3(.7,.6,0);
    }
    d_plane += fbm(q*.1+T*.1, .05);
    d = min(d, d_plane);
  }

  p.xz *= rotate(PI * 2. * sinc(mod(T, 4.), 1.));
  p.xy *= rotate(radians(-36.));
  
  float d_cacti=1e4;
  // body
  {
    vec3 q = p;
    float d1 = sdVerticalCapsule(q, 4., 1.4);
    d_cacti = min(d_cacti, d1);
  }
  // eye
  {
    vec3 q = p;
    q.x = abs(q.x);
    q -= vec3(.4, 3.4, 1.);
    q.yz *= rotate(radians(90.));

    float d1 = sdVerticalCapsule(q, 3., .2);
    d_cacti = max(d_cacti, -d1);
  }
  // mouth
  {
    vec3 q = p;
    q -= vec3(0,1.8,-1.4);
    float d1 = sdVerticalCapsule(q, .7, .18);
    d_cacti = max(d_cacti, -d1);
  }
  // hair
  {
    float dd = 1e4;
    vec3 q = p;
    q -= vec3(0,5.2,0);
    float d1 = sdVerticalCapsule(q, .8, .08);
    dd = min(dd, d1);
    {
      vec3 q = p;
      q.x = abs(q.x);
      q -= vec3(0.5,5.1,0);
      q.xy *= rotate(radians(30.));
      float d1 = sdVerticalCapsule(q, .8, .08);
      dd = min(dd, d1);
    }
    if(dd<0.1){
      col = vec3(.7,0,0);
    }
    d_cacti = smin(d_cacti, dd);
  }
  // left arm
  {
    vec3 q = p;
    q -= vec3(-1.,2.,0);
    q.xy *= rotate(radians(-90.));
    float d1 = sdVerticalCapsule(q, 1.8, .5);
    d_cacti = smin(d_cacti, d1);
    {
      vec3 q = p;
      q -= vec3(-3.,2.,0);
      float d1 = sdVerticalCapsule(q, 1.8, .5);
      d_cacti = smin(d_cacti, d1);
    }
  }
  // right arm
  {
    vec3 q = p;
    q -= vec3(3.,2.,0);
    q.xy *= rotate(radians(-90.));
    float d1 = sdVerticalCapsule(q, 1.8, .5);
    d_cacti = smin(d_cacti, d1);
    {
      vec3 q = p;
      q -= vec3(3.,.2,0);
      float d1 = sdVerticalCapsule(q, 1.8, .5);
      d_cacti = smin(d_cacti, d1);
    }
  }
  // left leg
  {
    vec3 q = p;
    q -= vec3(-.8,-.6,0);
    q.xy *= rotate(radians(-90.));
    float d1 = sdVerticalCapsule(q, 1.8, .6);
    d_cacti = smin(d_cacti, d1);
    {
      vec3 q = p;
      q -= vec3(-2.6,-3.,0);
      float d1 = sdVerticalCapsule(q, 2.4, .6);
      d_cacti = smin(d_cacti, d1);
    }
  }
  // right leg
  {
    vec3 q = p;
    q -= vec3(.8,-2.4,0);
    float d1 = sdVerticalCapsule(q, 1.8, .6);
    d_cacti = smin(d_cacti, d1);
    {
      vec3 q = p;
      q -= vec3(.8,-2.4,0);
      q.xy *= rotate(radians(90.));
      float d1 = sdVerticalCapsule(q, 2.4, .6);
      d_cacti = smin(d_cacti, d1);
    }
  }

  d_cacti += fbm(p, .02)*.4;
  d = min(d, d_cacti);
  
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

// https://www.shadertoy.com/view/MtsGWH
vec4 boxmap( in sampler2D s, in vec3 p, in vec3 n, in float k )
{
    // project+fetch
	vec4 x = texture( s, p.yz );
	vec4 y = texture( s, p.zx );
	vec4 z = texture( s, p.xy );
    
    // and blend
  vec3 m = pow( abs(n), vec3(k) );
	return (x*m.x + y*m.y + z*m.z) / (m.x + m.y + m.z);
}

float rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p).w;
    if(d<1e-3 || z>zMax) break;
    z += d;
  }

  return z;
}



// https://iquilezles.org/articles/rmshadows/
float softShadow(vec3 ro, vec3 rd, float mint, float tmax) {
  float res = 1.0;
  float t = mint;

  for(int i = 0; i < 100; i++) {
      float h = map(ro + rd * t).w;
      res = min(res, 8.0*h/t);
      t += clamp(h, 0.02, 0.10);
      if(h < 0.001 || t > tmax) break;
  }

  return clamp( res, 0.0, 1.0 );
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 100.;

  float z = rayMarch(ro, rd, 0.1, 50.);

  vec3 col = vec3(0);
  if(z<zMax) {
    vec3 p = ro + rd * z;

    vec4 M = map(p);
    vec3 nor = calcNormal(p);

    col = M.rgb;
    // col = boxmap(iChannel0, fract(p*.5), nor, 7.).rgb;

    vec3 l_dir = normalize(vec3(1,6,-4)-p);
    float diff = clamp(dot(l_dir, nor), 0., 1.);
    col *= diff*.6;
    
    // soft shadow
    float ss = clamp(softShadow(p, l_dir, .1, 10.), 0.1, 10.0);
    col *= ss;

    // blinn phong hight light
    // float spe = clamp(dot(normalize(l_dir-rd), nor),0.,1.);
    // col += spe * vec3(1)*.2;
  }

  col *= exp(-1e-4*z*z*z);
  col = pow(col, vec3(.62));
  O.rgb = col;

}