#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_1.png"

#define PI 3.141596
#define T iTime
#define dot2(v) dot(v,v)

// https://iquilezles.org/articles/distfunctions2d/
float sdCircle( vec2 p, float r ){
    return length(p) - r;
}
float sdBox( in vec2 p, in vec2 b ){
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdHeart( in vec2 p ){
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

mat2 rot2D(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float f = 1.;
  float a = .5;
  float n = 0.;
  for(float i=0.;i<4.;i++){
    n += a * noise(p*f);
    f *= 2.;
    a *= .5;
  }
  return n;
}

vec2 twist(vec2 p, vec2 scale, vec2 offset){
  p *= scale;
  p += offset;
  return p;
}

float domainWraping(vec2 p, vec2 scale, vec2 offset){
  // return texture(iChannel0, twist(p,scale,offset)).r;
  // return fbm(twist(p, scale, offset));
  float f = fbm(twist(p, scale, offset));
  return fbm(twist(p + f, scale, offset));
}

float glow(float d, float r, float ins){
  d = pow(r/d,ins);
  return d;
}

float sdf_gouyu(vec2 uv, float r) {
  return max(uv.y > 0. ? length(uv) - r : min(length(uv+vec2(r*.5,0)) - r*.5, length(uv-vec2(r,0))), -length(uv-vec2(r*.5,0))+r*.5);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R.y;
  O.rgb *= 0.5;
  O.a = 1.;
  float n1 = (1.+noise(uv*1e-1*vec2(.6,.4)) - .5);
  float d = sdCircle(uv*n1, 0.5);
  // d = max(d, -sdCircle(uv-vec2(-0.2,0.15), 0.1));
  // d = max(d, -sdCircle(uv-vec2(0.2,0.15), 0.1));
  // d = max(d, -sdHeart(uv*8.*rot2D(PI) + vec2(0.,.2)));
  // d = max(d, -sdBox(uv-vec2(0.,-0.3), vec2(0.2,0.05)));

  float s = smoothstep(0.01,0.,d);

  O.rgb += s;
}