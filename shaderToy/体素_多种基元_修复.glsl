// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_2.png"


// dray帮我做的修复 https://www.shadertoy.com/view/W3sBzN

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;


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

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

mat3 setCamera( in vec3 ro, in vec3 ta )
{
  float cr = 0.;
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );
}

// 主场景
float map(vec3 p){
  float d = sdTorus(p, vec2(5,1.4));
  float d1 = p.y-5.+noise(p.xz*.006+T*vec2(0,.01))*10.;
  float d2 = length(p) - 15.;
  d1 = max(d1, -d2);

  d = min(d, d1);

  return d;
}


// 体素单元形状
float map_el(vec3 p, float seed){
  float d=1e5;
  if(seed<.3){
    d = length(p)-.5;
  }
  else if(seed<.6){
    d = sdBoxFrame(p, vec3(.4), .04);
  }
  else if(seed<1.){
    d = sdRoundBox(p, vec3(.4), .1);
  }
  return d;
}


/*
xor voxel map: https://www.shadertoy.com/view/XctSz8
*/
float voxel_step_max = 100.;
bool map_voxel(vec3 ro, vec3 rd, inout vec3 vox,
                inout vec3 p,
                inout float shape_val, inout float dep_z){
  
  vec3 sig = sign(rd);
  vec3 stp = sig / rd;
  vec3 dep = ((vox-ro + 0.5) * sig + 0.5) * stp;

  vec3 axi;
  float steps = 0.0;

  bool hit = false;
  for(float i = 0.0; i<voxel_step_max; i++){
    //Check map
    float d = map(vox);
    /*
    在检测到形状后继续使用raymarch来绘制体素形状
    并且跳出循环的依据改为,raymarch碰撞到体素形状
    */
    if(d<0.){
      shape_val = hash13(vox);

      float z = 0.;
      for(float i=0.;i<20.;i++){
        p = ro + rd * z;
        p -= vox + .5;
        float d = map_el(p, shape_val);
        z+=d;

        if(d<EPSILON){
          hit = true;
          break;
        }
        if(z>50.) break;
      }

      if(hit) {
        break;
      }
    }
    if(hit){
      return hit;
    }

    //Increment steps
    steps++;
    
    //Select the closest voxel face axis
    axi = dep.x<dep.z? 
        ( dep.x<dep.y? vec3(1,0,0) : vec3(0,1,0) ):
        ( dep.z<dep.y? vec3(0,0,1) : vec3(0,1,0) );
    
    //Step one voxel along this axis
    vox += sig * axi;
    //Set the length to the next voxel
    dep += stp * axi;
  }

  dep_z = steps / voxel_step_max;

  return hit;
}


// https://iquilezles.org/articles/normalsSDF/
vec3 calcNormal( in vec3 pos, float shape_val )
{
    vec2 e = vec2(1.0,-1.0);
    const float eps = 0.0005;
    return normalize( 
              e.xyy*map_el( pos + e.xyy*eps, shape_val ) + 
              e.yyx*map_el( pos + e.yyx*eps, shape_val ) + 
              e.yxy*map_el( pos + e.yxy*eps, shape_val ) + 
              e.xxx*map_el( pos + e.xxx*eps, shape_val ) );
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,5.,-12.);
  ro.xz = rotate(T*.3)*ro.xz;
  ro.yz = rotate(T*.3)*ro.yz;
  if(iMouse.z>0.){
    vec2 m = (iMouse.xy*2.-R)/R;
    ro.xz = rotate(m.x*2.)*ro.xz;
    ro.yz = rotate(m.y*2.)*ro.yz;
  }
  vec3 rd = setCamera(ro, vec3(0)) * normalize(vec3(uv, 1.));
  vec3 vox = floor(ro);

  float shape_val = 0.;
  float dep_z = 0.;
  vec3 p;
  bool hit = map_voxel(ro, rd, vox, p, shape_val, dep_z);

  float z = 0.;

  vec3 l_pos = vec3(-10,10,-10);

  vec3 col = vec3(0);
  if(hit){
    col = s1(vec3(3,2,1)+hash13(vox)*10.);

    // vec3 l_dir = normalize(vec3(4,4,-4)-p);
    vec3 l_dir = normalize(l_pos-p);
    vec3 nor = calcNormal(p, shape_val);

    float diff = max(0., dot(l_dir, nor));
    float spe = pow(max(0., dot(reflect(-l_dir, nor), -rd)), 5.);
    col = diff*col*1.6 + spe;

    vec3 sky = nor.y*vec3(.2,.2,.2);
    O.rgb += col + sky;
  }

  // 雾,场景深度渐变,击中的体素背景隐藏
  O.rgb *= exp(-10.*dep_z*dep_z*dep_z);
}