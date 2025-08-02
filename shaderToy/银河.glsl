// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

#define cmul(a,b) vec2(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y)

float swirls(vec3 p) {
	vec3 c=p;
	float d=.1;
	for (float i=.0; i<5.; i++) {
		p=abs(p)/dot(p,p)-.7;
		// p=abs(p)/dot(p,p)-(sin(T)*.5+.5);
		p.yz=cmul(p.yz,p.zx);
		p=p.zxy;
		d+=exp(-19.*abs(dot(p,c)));
	}
	return d;
}

// https://www.shadertoy.com/view/lsKcDD
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);            // 相机前
	vec3 cp = vec3(sin(cr), cos(cr),0.0);  // 滚角
	vec3 cu = normalize( cross(cw,cp) );   // 相机右
	vec3 cv = normalize( cross(cu,cw) );   // 相机上
  return mat3( cu, cv, cw );
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-1);
  vec2 m = iMouse.xy/R*6.;
  // if(iMouse.z > 0.){
    // ro.xyz = vec3(cos(m.x), cos(m.y*2.), sin(m.x))*1.;
  // }

  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));

  float zMax = 50.;
  vec3 col = vec3(0);
  float z = .1;
  float d = 0.;
  for(float i=0.;i<100.;i++){
    z+=exp(-z*.64)*exp(-d*2.05);
    vec3 p = ro + rd * z;

    if(iMouse.z>0.){
      p.xy *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    d = swirls(p);
    col += (.5+.5*sin(vec3(3,2,1)+d*3.))*exp(.5*d);

    if(z>zMax || d<EPSILON) break;
  }

  col = tanh(col / 1e2);

  O.rgb = col;
}