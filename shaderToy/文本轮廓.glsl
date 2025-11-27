// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)



float l( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}
#define dot2(v) dot(v,v)
float s( in vec2 pos, in vec2 A, in vec2 B, in vec2 C )
{    
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    float kk = 1.0/dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);      
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx-3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    if( h >= 0.0) 
    { 
        h = sqrt(h);
        vec2 x = (vec2(h,-h)-q)/2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = clamp( uv.x+uv.y-kx, 0.0, 1.0 );
        res = dot2(d + (c + b*t)*t);
    }
    else
    {
        float z = sqrt(-p);
        float v = acos( q/(p*z*2.0) ) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3  t = clamp(vec3(m+m,-n-m,n-m)*z-kx,0.0,1.0);
        res = min( dot2(d+(c+b*t.x)*t.x),
                   dot2(d+(c+b*t.y)*t.y) );
        // the third root cannot be the closest
        // res = min(res,dot2(d+(c+b*t.z)*t.z));
    }
    return sqrt( res );
}

float char(vec2 p){ 


float d0 = l(p, vec2(0.485, -0.459), vec2(0.485, -0.459));
float d1 = s(p, vec2(0.485, -0.459), vec2(0.54, -0.47100000000000003), vec2(0.603, -0.4885));
d0 = min(d1, d0);
float d2 = s(p, vec2(0.603, -0.4885), vec2(0.666, -0.506), vec2(0.686, -0.506));
d0 = min(d2, d0);
float d3 = s(p, vec2(0.686, -0.506), vec2(0.706, -0.506), vec2(0.724, -0.4985));
d0 = min(d3, d0);
float d4 = s(p, vec2(0.724, -0.4985), vec2(0.742, -0.491), vec2(0.742, -0.482));
d0 = min(d4, d0);
float d5 = l(p, vec2(0.742, -0.482), vec2(0.742, -0.482));
d0 = min(d5, d0);
float d6 = s(p, vec2(0.742, -0.482), vec2(0.742, -0.468), vec2(0.6910000000000001, -0.457));
d0 = min(d6, d0);
float d7 = l(p, vec2(0.6910000000000001, -0.457), vec2(0.6910000000000001, -0.457));
d0 = min(d7, d0);
float d8 = l(p, vec2(0.6910000000000001, -0.457), vec2(0.47400000000000003, -0.41000000000000003));
d0 = min(d8, d0);
float d9 = s(p, vec2(0.47400000000000003, -0.41000000000000003), vec2(0.43, -0.228), vec2(0.366, -0.131));
d0 = min(d9, d0);
float d10 = s(p, vec2(0.366, -0.131), vec2(0.302, -0.034), vec2(0.2185, 0.0125));
d0 = min(d10, d0);
float d11 = s(p, vec2(0.2185, 0.0125), vec2(0.135, 0.059000000000000004), vec2(0.117, 0.059000000000000004));
d0 = min(d11, d0);
float d12 = l(p, vec2(0.117, 0.059000000000000004), vec2(0.117, 0.059000000000000004));
d0 = min(d12, d0);
float d13 = s(p, vec2(0.117, 0.059000000000000004), vec2(0.113, 0.059000000000000004), vec2(0.113, 0.056));
d0 = min(d13, d0);
float d14 = l(p, vec2(0.113, 0.056), vec2(0.113, 0.056));
d0 = min(d14, d0);
float d15 = s(p, vec2(0.113, 0.056), vec2(0.113, 0.049), vec2(0.15, 0.024));   
d0 = min(d15, d0);
float d16 = l(p, vec2(0.15, 0.024), vec2(0.15, 0.024));
d0 = min(d16, d0);
float d17 = s(p, vec2(0.15, 0.024), vec2(0.343, -0.101), vec2(0.421, -0.399)); 
d0 = min(d17, d0);
float d18 = l(p, vec2(0.421, -0.399), vec2(0.421, -0.399));
d0 = min(d18, d0);
float d19 = s(p, vec2(0.421, -0.399), vec2(0.34600000000000003, -0.381), vec2(0.3085, -0.381));
d0 = min(d19, d0);
float d20 = s(p, vec2(0.3085, -0.381), vec2(0.271, -0.381), vec2(0.2525, -0.3925));
d0 = min(d20, d0);
float d21 = s(p, vec2(0.2525, -0.3925), vec2(0.234, -0.404), vec2(0.234, -0.41000000000000003));
d0 = min(d21, d0);
float d22 = s(p, vec2(0.234, -0.41000000000000003), vec2(0.234, -0.41600000000000004), vec2(0.256, -0.417));
d0 = min(d22, d0);
float d23 = l(p, vec2(0.256, -0.417), vec2(0.256, -0.417));
d0 = min(d23, d0);
float d24 = s(p, vec2(0.256, -0.417), vec2(0.303, -0.419), vec2(0.432, -0.446));
d0 = min(d24, d0);
float d25 = l(p, vec2(0.432, -0.446), vec2(0.432, -0.446));
d0 = min(d25, d0);
float d26 = s(p, vec2(0.432, -0.446), vec2(0.451, -0.537), vec2(0.451, -0.597));
d0 = min(d26, d0);
float d27 = s(p, vec2(0.451, -0.597), vec2(0.451, -0.657), vec2(0.4425, -0.67));
d0 = min(d27, d0);
float d28 = s(p, vec2(0.4425, -0.67), vec2(0.434, -0.683), vec2(0.434, -0.6920000000000001));
d0 = min(d28, d0);
float d29 = l(p, vec2(0.434, -0.6920000000000001), vec2(0.434, -0.6920000000000001));
d0 = min(d29, d0);
float d30 = s(p, vec2(0.434, -0.6920000000000001), vec2(0.434, -0.707), vec2(0.4525, -0.707));
d0 = min(d30, d0);
float d31 = s(p, vec2(0.4525, -0.707), vec2(0.47100000000000003, -0.707), vec2(0.505, -0.6855));
d0 = min(d31, d0);
float d32 = s(p, vec2(0.505, -0.6855), vec2(0.539, -0.664), vec2(0.539, -0.6505));
d0 = min(d32, d0);
float d33 = s(p, vec2(0.539, -0.6505), vec2(0.539, -0.637), vec2(0.531, -0.625));
d0 = min(d33, d0);
float d34 = s(p, vec2(0.531, -0.625), vec2(0.523, -0.613), vec2(0.485, -0.459));
d0 = min(d34, d0);
d0 = min(d34, d0);
float d35 = l(p, vec2(0.704, -0.655), vec2(0.704, -0.655));
d0 = min(d35, d0);
float d36 = s(p, vec2(0.704, -0.655), vec2(0.759, -0.655), vec2(0.7835, -0.632));
d0 = min(d36, d0);
float d37 = s(p, vec2(0.7835, -0.632), vec2(0.808, -0.609), vec2(0.808, -0.5835));
d0 = min(d37, d0);
float d38 = s(p, vec2(0.808, -0.5835), vec2(0.808, -0.558), vec2(0.7775, -0.558));
d0 = min(d38, d0);
float d39 = s(p, vec2(0.7775, -0.558), vec2(0.747, -0.558), vec2(0.6985, -0.5945));
d0 = min(d39, d0);
float d40 = s(p, vec2(0.6985, -0.5945), vec2(0.65, -0.631), vec2(0.65, -0.643));
d0 = min(d40, d0);
float d41 = s(p, vec2(0.65, -0.643), vec2(0.65, -0.655), vec2(0.704, -0.655)); 
d0 = min(d41, d0);
d0 = min(d41, d0);
float d42 = l(p, vec2(0.5670000000000001, -0.088), vec2(0.5670000000000001, -0.088));
d0 = min(d42, d0);
float d43 = s(p, vec2(0.5670000000000001, -0.088), vec2(0.5710000000000001, -0.037), vec2(0.6035, -0.0035));
d0 = min(d43, d0);
float d44 = s(p, vec2(0.6035, -0.0035), vec2(0.636, 0.03), vec2(0.733, 0.03)); 
d0 = min(d44, d0);
float d45 = l(p, vec2(0.733, 0.03), vec2(0.733, 0.03));
d0 = min(d45, d0);
float d46 = s(p, vec2(0.733, 0.03), vec2(0.783, 0.03), vec2(0.8345, 0.019));   
d0 = min(d46, d0);
float d47 = s(p, vec2(0.8345, 0.019), vec2(0.886, 0.008), vec2(0.906, -0.021));
d0 = min(d47, d0);
float d48 = s(p, vec2(0.906, -0.021), vec2(0.926, -0.05), vec2(0.9480000000000001, -0.138));
d0 = min(d48, d0);
float d49 = l(p, vec2(0.9480000000000001, -0.138), vec2(0.9480000000000001, -0.138));
d0 = min(d49, d0);
float d50 = s(p, vec2(0.9480000000000001, -0.138), vec2(0.9550000000000001, -0.166), vec2(0.9615, -0.166));
d0 = min(d50, d0);
float d51 = s(p, vec2(0.9615, -0.166), vec2(0.968, -0.166), vec2(0.968, -0.1355));
d0 = min(d51, d0);
float d52 = s(p, vec2(0.968, -0.1355), vec2(0.968, -0.105), vec2(0.9715, -0.073));
d0 = min(d52, d0);
float d53 = s(p, vec2(0.9715, -0.073), vec2(0.975, -0.041), vec2(0.9795, -0.028));
d0 = min(d53, d0);
float d54 = s(p, vec2(0.9795, -0.028), vec2(0.984, -0.015), vec2(0.984, 0.004));
d0 = min(d54, d0);
float d55 = s(p, vec2(0.984, 0.004), vec2(0.984, 0.023), vec2(0.967, 0.0425)); 
d0 = min(d55, d0);
float d56 = s(p, vec2(0.967, 0.0425), vec2(0.9500000000000001, 0.062), vec2(0.89, 0.0805));
d0 = min(d56, d0);
float d57 = s(p, vec2(0.89, 0.0805), vec2(0.8300000000000001, 0.099), vec2(0.762, 0.099));
d0 = min(d57, d0);
float d58 = l(p, vec2(0.762, 0.099), vec2(0.762, 0.099));
d0 = min(d58, d0);
float d59 = s(p, vec2(0.762, 0.099), vec2(0.643, 0.099), vec2(0.595, 0.059500000000000004));
d0 = min(d59, d0);
float d60 = s(p, vec2(0.595, 0.059500000000000004), vec2(0.547, 0.02), vec2(0.531, -0.061));
d0 = min(d60, d0);
float d61 = l(p, vec2(0.531, -0.061), vec2(0.531, -0.061));
d0 = min(d61, d0);
float d62 = s(p, vec2(0.531, -0.061), vec2(0.495, -0.037), vec2(0.4535, -0.023));
d0 = min(d62, d0);
float d63 = s(p, vec2(0.4535, -0.023), vec2(0.41200000000000003, -0.009000000000000001), vec2(0.3975, -0.009000000000000001));
d0 = min(d63, d0);
float d64 = s(p, vec2(0.3975, -0.009000000000000001), vec2(0.383, -0.009000000000000001), vec2(0.383, -0.0155));
d0 = min(d64, d0);
float d65 = s(p, vec2(0.383, -0.0155), vec2(0.383, -0.022), vec2(0.405, -0.031));
d0 = min(d65, d0);
float d66 = l(p, vec2(0.405, -0.031), vec2(0.405, -0.031));
d0 = min(d66, d0);
float d67 = s(p, vec2(0.405, -0.031), vec2(0.45, -0.051000000000000004), vec2(0.528, -0.111));
d0 = min(d67, d0);
float d68 = l(p, vec2(0.528, -0.111), vec2(0.528, -0.111));
d0 = min(d68, d0);
float d69 = s(p, vec2(0.528, -0.111), vec2(0.525, -0.177), vec2(0.525, -0.2245));
d0 = min(d69, d0);
float d70 = s(p, vec2(0.525, -0.2245), vec2(0.525, -0.272), vec2(0.5275, -0.3005));
d0 = min(d70, d0);
float d71 = s(p, vec2(0.5275, -0.3005), vec2(0.53, -0.329), vec2(0.53, -0.354));
d0 = min(d71, d0);
float d72 = s(p, vec2(0.53, -0.354), vec2(0.53, -0.379), vec2(0.5275, -0.386));
d0 = min(d72, d0);
float d73 = s(p, vec2(0.5275, -0.386), vec2(0.525, -0.393), vec2(0.525, -0.4));
d0 = min(d73, d0);
float d74 = s(p, vec2(0.525, -0.4), vec2(0.525, -0.40700000000000003), vec2(0.5365, -0.40700000000000003));
d0 = min(d74, d0);
float d75 = s(p, vec2(0.5365, -0.40700000000000003), vec2(0.548, -0.40700000000000003), vec2(0.5725, -0.387));
d0 = min(d75, d0);
float d76 = s(p, vec2(0.5725, -0.387), vec2(0.597, -0.367), vec2(0.597, -0.3545));
d0 = min(d76, d0);
float d77 = s(p, vec2(0.597, -0.3545), vec2(0.597, -0.342), vec2(0.588, -0.3275));
d0 = min(d77, d0);
float d78 = s(p, vec2(0.588, -0.3275), vec2(0.579, -0.313), vec2(0.5725, -0.2635));
d0 = min(d78, d0);
float d79 = s(p, vec2(0.5725, -0.2635), vec2(0.5660000000000001, -0.214), vec2(0.5650000000000001, -0.14200000000000002));
d0 = min(d79, d0);
float d80 = l(p, vec2(0.5650000000000001, -0.14200000000000002), vec2(0.5650000000000001, -0.14200000000000002));
d0 = min(d80, d0);
float d81 = s(p, vec2(0.5650000000000001, -0.14200000000000002), vec2(0.633, -0.2), vec2(0.669, -0.245));
d0 = min(d81, d0);
float d82 = s(p, vec2(0.669, -0.245), vec2(0.705, -0.29), vec2(0.715, -0.335));
d0 = min(d82, d0);
float d83 = l(p, vec2(0.715, -0.335), vec2(0.715, -0.335));
d0 = min(d83, d0);
float d84 = s(p, vec2(0.715, -0.335), vec2(0.719, -0.355), vec2(0.7325, -0.355));
d0 = min(d84, d0);
float d85 = s(p, vec2(0.7325, -0.355), vec2(0.746, -0.355), vec2(0.772, -0.337));
d0 = min(d85, d0);
float d86 = s(p, vec2(0.772, -0.337), vec2(0.798, -0.319), vec2(0.798, -0.3095));
d0 = min(d86, d0);
float d87 = s(p, vec2(0.798, -0.3095), vec2(0.798, -0.3), vec2(0.7845, -0.2915));
d0 = min(d87, d0);
float d88 = s(p, vec2(0.7845, -0.2915), vec2(0.771, -0.28300000000000003), vec2(0.754, -0.265));
d0 = min(d88, d0);
float d89 = s(p, vec2(0.754, -0.265), vec2(0.737, -0.247), vec2(0.727, -0.233));
d0 = min(d89, d0);
float d90 = l(p, vec2(0.727, -0.233), vec2(0.727, -0.233));
d0 = min(d90, d0);
float d91 = s(p, vec2(0.727, -0.233), vec2(0.6920000000000001, -0.188), vec2(0.6575, -0.158));
d0 = min(d91, d0);
float d92 = s(p, vec2(0.6575, -0.158), vec2(0.623, -0.128), vec2(0.5670000000000001, -0.088));
d0 = min(d92, d0);
return d0;
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  uv.y = -uv.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 col = vec3(0);
  float d = char(uv);
  d = S(4./R.y,0.,d);
  col += d;

  O.rgb = col;
}