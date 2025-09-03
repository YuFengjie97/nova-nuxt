// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
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

float sdBase(vec3 p, vec3 id, float sp){
  float d;
  if(sin(T*2.)<0.){
    d = sdBox(p, vec3(.4)*sp);
  }else{
    if(mod(id.x+id.y+id.z, 2.)<=.5){
      d = sdBox(p, vec3(.2)*sp);
    }else{
      d = length(p)-.4*sp;
      // d = sdBox(p, vec3(.4,.2,.4)*sp)-.1*sp;
    }
  }
  return d*.2;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float s = 1.4;
    vec3 id = round(p/s);
    float ra = 2.4;

    float d = 1e20;

    if(dot(id,id)>ra*ra*ra){
      id = round(normalize(id)*ra);
    }
    int range = 1;
    for(int x=-range;x<range;x++){
    for(int y=-range;y<range;y++){
    for(int z=-range;z<range;z++){
      vec3 idd = id + vec3(x,y,z);
      // idd = clamp(idd, -3., 3.);
      if(dot(idd,idd)<=ra*ra*ra){
        vec3 q = p - idd*s;
        // float d1 = sdBox(q, vec3(.3)*s);
        float d1 = sdBase(q, idd, s);
        d = min(d,d1);
      }
    }
    }
    }

    // d = max(0.,d)*.1;
    d = abs(d) + .008;

    vec3 c = sin(vec3(3,2,1)+dot(id,id))*.5+.5;
    col += c*pow(.1/d,2.);
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e3);

  O.rgb = col;
}