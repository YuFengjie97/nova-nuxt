// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-6;

vec3 ro = vec3(0);
vec3 rd = vec3(0);


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

// iq's sdf function
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
float sdSphere(vec3 p, float r){
  return length(p) - r;
}

// David Hoskins hash function
float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
} 

vec3 col = vec3(0);
float d_repetition(vec3 p) {
  vec2 m = (iMouse.xy*2.-iResolution.xy)/iResolution.xy*6.;
  if(iMouse.z>0.){
    p.xz*=rotate(m.x);
    p.yz*=rotate(m.y);
  }else{
    // p.xz*=rotate(T*.4);
    // p.yz*=rotate(T*.4);
  }
  
  vec3 id = floor(p);
  vec3 cen = id + .5;
  float d = length(p-cen)-.45;
  
  col = s1(vec3(3,2,1)+(id.x+id.y+id.z)*4.);
  return d;
}


float d_voxel(){
  vec3 pos = ro;
  vec3 sig = sign(rd);
  vec3 stp = sig / rd;
  vec3 vox = floor(pos);
  vec3 dep = ((vox-pos + 0.5) * sig + 0.5) * stp;
  vec3 axi;

  float d = 1e10;
    
  for(float i = 0.0; i<50.; i++){
    d = length(vox) - 4.;
    if(d<.1){
      break;
    }

    axi = dep.x<dep.z? 
          ( dep.x<dep.y? vec3(1,0,0) : vec3(0,1,0) ):
          ( dep.z<dep.y? vec3(0,0,1) : vec3(0,1,0) );
    
    vox += sig * axi;
    dep += stp * axi;
  }
  return d;
}

float map(vec3 p){
  float d1 = d_repetition(p);
  float d2 = d_voxel();
  float d = max(d1, d2);
  return d;
}


// https://www.shadertoy.com/view/lsKcDD
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = map( pos + h*nor );
        occ += (h-d)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 1.5*occ, 0.0, 1.0 );    
}



// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
            e.xyy*map( pos + e.xyy*eps ) + 
					  e.yyx*map( pos + e.yyx*eps ) + 
					  e.yxy*map( pos + e.yxy*eps ) + 
					  e.xxx*map( pos + e.xxx*eps ) );
}



struct RM{
  float z;
  bool hit;
};

RM rayMarch(vec3 ro, vec3 rd, float zMin, float zMax){
  float z = zMin;
  bool hit = false;
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    float d = map(p);
    if(d<EPSILON ){
      hit = true;
      break;
    }
    if(z>zMax) break;
    z += d;
  }

  return RM(z, hit);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  ro = vec3(0.,0.,-6.);
  rd = normalize(vec3(uv, 1.));

  float zMax = 50.;

  RM rm = rayMarch(ro, rd, 0.1, zMax);
  bool hit = rm.hit;
  float z = rm.z;

  if(hit) {
    vec3 p = ro + rd * z;

    vec3 nor = calcNormal(p);

    vec3 l_dir = normalize(vec3(0,0,-1));
    float diff = max(0., dot(l_dir, nor));

    // float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    float spe = pow(max(0., dot(normalize(l_dir-rd), nor)), 100.);

    col = col * diff + spe;

  }else{
    col = vec3(0);
  }

  col *= exp(-5e-3*z*z*z);
  col = pow(col, vec3(.6545));
  O.rgb = col;

}