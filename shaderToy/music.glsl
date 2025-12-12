// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/sound/shaderToy_1.mp3"
#iChannel0 "file://D:/workspace/nova-nuxt/public/sound/savageLove.aac"


#define T iTime
#define PI 3.141592
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

float freqs[16];
float freq = 0.;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  // https://www.shadertoy.com/view/4slGz4
  // pow -- 加强局部特征区分
  // s*  -- 增强整体特征
  // .3* -- 获取低频部分,.3是大概的范围
  for( int i=0; i<16; i++ ){
    freqs[i] = //clamp(
                    2.*pow( 
                            texture( 
                                    iChannel0,
                                    vec2( 0.05 + 0.3*float(i)/16.0, 0.25 ) ).x,
                            3.0 );
                    //,0.0, 1.0 );
    freq += freqs[i]/16.;
  }

  vec3 ro = vec3(0.,0.,-10.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = .1;
  
  
 // float f = freqs[3];
  float f = freq;
  
  float ang = mix(T, T+f*2., .6);
  //float ang = T+f*10.;
  mat2 mx = rotate(ang);
  mat2 my = rotate(ang);


  vec3 col = vec3(0);
  float i=0.;
  while(i++<80.){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;


    float d = sdBoxFrame(p, vec3(4.), .5);
    d = abs(d)*.3 + .01;

    float range = 4.*freq+.0;
    float glow = S(range,0.,abs(p.y)) + S(range,0.,abs(p.x)) + S(range,0.,abs(p.z));
    glow = glow*50.+1.;
    col += s1(vec3(3,2,1)+freq*1.+dot(abs(p), vec3(.2)))*glow/d;
    
    z += d;
  }

  col = tanh(col / 5e2);

  O.rgb = col;
}