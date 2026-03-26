
/*
参考shader: https://www.shadertoy.com/view/7cX3Dl
            https://www.shadertoy.com/view/7cjGRR


Path,两个维度，一个是时间来更新相机位置（ro）,另一个是空间来扭曲隧道（将其变为Path的样子）
相机通过Path(time)来更新他的位置，然后投射到场景中，相机到达Path(time)位置
此时在场景中的Path依照相机位置p.z扭曲空间。
通俗的讲。相机：我已经到达了p=Path(time)的地方，你（场景map）现在将整个空间给我按照Path(p.z)给我扭曲成Path的样子


关于path函数的选择，保证弦函数的频率小可以，防止过快的相机rd变化


对不发光物体着色，O += glow_r / z_obj其实是使用p点到物体距离，做的“最后一次”发光
这种最后一次的体积光来着色，几乎不会产生伪影（比d小于阈值进行break着色好多了）
或者直接按照体积光O+=glow_r/d_obj每次循环累加，然后tanh统一调整
// diatribes就是这么做的
//https://www.shadertoy.com/view/7cX3Dl
  for(; i++ < 1e2;)
        p = ro + D * d,
        d += s = map(p) * .5,
        o += lights + 1./max(s, .01);   // s是到map中所有物体的单次步进距离，这样相当于给所有物体进行了纯白的着色


发光的部分，用额外的变量来在map中单独记录，因为map在raymarch中每次使用。这样可以很方便的区分，谁发光，谁不发光

//-------------
关于反射
在第一次步进结束后，p到达了物体表面，求得此处法线
通过reflect获取视线的反射方向
进行第二次步进（反射的步进）
我调试时发现，getNormal中的精度对发射的影响特别大.001跟.005差大发了

*/


#define T iTime
#define t_path T*2.
#define s1(v) (sin(v)*.5+.5)
#define P(z) vec3(cos((z)*.1)*2.,cos((z)*.2)*4.,(z))


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float tun(vec3 p){
  p = abs(p);
  float d = min(-p.y-1.*p.x+5., 2.-p.y);

  return d;
}

vec3 col_glow = vec3(0);
float z_tun = 0.;
float map(vec3 p){

  // 按照p.z来扭曲整个空间
  vec3 path = P(p.z);
  p.xy -= path.xy;

  float d = tun(p);
  z_tun += d;

  {
    vec2 offset = vec2(cos(p.z), sin(p.z))*1.;
    float d1 = length(p.xy-offset)-.1;
    d = min(d, d1); // 在构造体积光前，将距离场合并到总距离场
    d1 = abs(d1)*.6 + .01;
    col_glow += 1.*vec3(1,0,0)/d1;
  }

  {
    vec2 offset = vec2(sin(T)*2., cos(T)*2.);
    float d1 = length(p-vec3(offset,t_path+7.))-.1;
    d = min(d, d1);
    d1 = abs(d1)*.8 + .01;
    col_glow += vec3(0,0,1)*pow(1./d1,2.);
  }

  return d;
}


// https://www.shadertoy.com/view/4ttSWf
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);           
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  
	vec3 cu = normalize( cross(cw,cp) );  
	vec3 cv = normalize( cross(cu,cw) );  
  return mat3( cu, cv, cw );
}
// https://iquilezles.org/articles/normalsSDF/
vec3 getNormal(vec3 p){
  const float h = .001;
  const vec2 k = vec2(1,-1);
  vec3 n = normalize(k.xyy*map( p + k.xyy*h ) + 
                     k.yyx*map( p + k.yyx*h ) + 
                     k.yxy*map( p + k.yxy*h ) + 
                     k.xxx*map( p + k.xxx*h ) );
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 p;
  float z=0.;
  vec3 ro = P(t_path);
  vec3 ta = P(t_path+2.0);
  vec3 rd = setCamera(ro, ta, 0.) * normalize(vec3(uv, 1.));

  for(float i=0.;i<100.;i++){
    p = ro+rd*z;
    float d = map(p)*.6;
    z += d;
  }
  O.rgb += col_glow;
  O.rgb = tanh(O.rgb/1e3);
  O.rgb += 4./z_tun*vec3(0,1,0); // “最后一次”体积光
  // O.rgb += 4./z_tun; // “最后一次”体积光


  vec3 n = getNormal(p);

  O.rgb += .5*max(dot(-normalize(rd),n),0.);

  vec3 p_ref;
  vec3 col_ref=vec3(0);
  z = 0.;
  col_glow = vec3(0); // 重置
  p += n*.1; // 射线起点偏移，防止击中起始位置

  vec3 ref = reflect(rd, n);
  for(float i=0.;i<100.;i++){
    p_ref = p + ref * z;
    float d = map(p_ref);
    z += d*.6;
    col_ref += col_glow/10. + 1./max(d, .01);
  }
  // col_ref += col_glow/10.;
  // col_ref = tanh(col_ref);
  // col_ref += 4./z_tun*vec3(0,1,0);
  // O.rgb += O.rgb*col_ref/5.;
  O.rgb *= col_ref;

  O.rgb = tanh(O.rgb/1e4);
}