#iChannel0 "./pic/noise_64.png"
#iChannel1 "./pic/rock.png"

#define T iTime

float noise(vec2 p){
  return textureLod(iChannel1, p, 1.).r;
}


float fbm(vec2 p){
  float a = 1.;
  float f = 1.;
  float n = 0.;
  for(float i=0.;i<6.;i++){
    n += noise(p*f)*a;
    f*=2.;
    a*=.5;
  }
  return n;
}

float domainWarping(vec2 p){
  float x = fbm(p+vec2(.2,.4));
  float y = fbm(p+vec2(.1,.3));

  return fbm(p+1.*vec2(x,y));
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
  float pix = 1./R.y;

  float n1 = noise(uv*.2 + .1 +vec2( T*.1));
  float n2 = noise(uv*.2 + .2 +vec2(-T*.1));
  vec2 nn = vec2(n1, n2);

  float n = domainWarping(uv*.04 + nn*.03);

  float d = sdSegment(uv, vec2(0,-.8), vec2(0,.8));

  float gn = smoothstep(1000.*pix, 0., n);
  gn -= noise(uv*vec2(.2)-nn*.1);

  float gd = pow(.015/max(d, 0.01), 2.);
  // float gd = exp(-d*20.);

  O.rgb += mix(vec3(0), vec3(0,1,0), gn+gd);
}