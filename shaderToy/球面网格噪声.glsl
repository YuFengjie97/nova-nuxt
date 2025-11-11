// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}


float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
vec2 sphIntersect( in vec3 ro, in vec3 rd, in vec3 ce, float ra )
{
    vec3 oc = ro - ce;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - ra*ra;
    float h = b*b - c;
    if( h<0.0 ) return vec2(-1.0); // no intersection
    h = sqrt( h );
    return vec2( -b-h, -b+h );
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


vec3 Tonemap_ACES(vec3 x)
{
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (x * (a * x + b)) / (x * (c * x + d) + e);
}


vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

// Voronoi noise on the sphere
// https://www.shadertoy.com/view/t32yzd
vec2 voronoi_sphere(vec3 uvw)
{
	vec3 cell = floor(uvw);
	float radius = length(uvw);
	float center = .5;
	float dist = 1.;

  // 到最近中心点的距离,到次近中心点的距离
  vec2 min_d = vec2(1e4);

	for(int x = -1; x <= 1; x++)
	for(int y = -1; y <= 1; y++)
	for(int z = -1; z <= 1; z++)
	{
        vec3 by = cell + vec3(x, y, z);
        float sphere = abs(length(by + center) - radius);

        if (sphere < center)
        {
            vec3 dir = hash33(by+sin(T*.0001)) + by;
            // dist = min(dist, length((dir / length(dir) * radius) - uvw));
            dist = length((dir / length(dir) * radius) - uvw);

            if(dist<min_d.x){
              min_d.y = min_d.x;
              min_d.x = dist;
            }else if(dist < min_d.y){
              min_d.y = dist;
            }
		    }
	}
  
	// return dist;
  return min_d;
}
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R*6.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);
  // vec3 rd = normalize(vec3(uv, 1.));
  vec3 rd = setCamera(ro, vec3(0), 0.)*normalize(vec3(uv, 1.));
  vec3 col = vec3(0);

  vec3 sph_cen = vec3(0);
  vec2 hit = sphIntersect(ro, rd, sph_cen, 4.);
  if(hit.x>0.){
    vec3 p = ro + rd*hit.x;
    // p.xz += sin(p.y*3.)/3.;
    // p.xz *= rotate(p.y*.1);
    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    vec3 nor = normalize(p-sph_cen);

    vec3 l_dir = normalize(vec3(4,4,-10) - p);
    float diff = max(0.,dot(l_dir, nor));
    // float spe = pow(max(0.,dot(reflect(-l_dir, nor), -rd)),30.);
    float spe = pow(max(0.,dot(normalize(l_dir-rd),nor)),30.);

    vec3 obj_col = vec3(0.5);
    col += obj_col*.1 + obj_col*diff*.3 + spe*.5;

    vec2 vor = voronoi_sphere(p);
    // col += pow(.1/(vor.y-vor.x), 2.) * vec3(1,1,0);
    col += pow(.2/(vor.y-vor.x), 2.) * s1(vec3(3,2,1)+p*2.);
  }

  col = Tonemap_ACES(col);
  O.rgb = col;
}