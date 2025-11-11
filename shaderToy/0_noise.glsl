
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

// voronoi 3D https://www.shadertoy.com/view/4lSXzh
float Voronesque( in vec3 p ){
    
    // Skewing the cubic grid, then determining the first vertex.
    vec3 i  = floor(p + dot(p, vec3(.333333)) );  p -= i - dot(i, vec3(.166666)) ;
    
    // Breaking the skewed cube into tetrahedra with partitioning planes, then determining which side of the 
    // intersecting planes the skewed point is on. Ie: Determining which tetrahedron the point is in.
    vec3 i1 = step(p.yzx, p), i2 = max(i1, 1. - i1.zxy); i1 = min(i1, 1. - i1.zxy);    
    
    // Using the above to calculate the other three vertices. Now we have all four tetrahedral vertices.
    vec3 p1 = p - i1 + .166666, p2 = p - i2 + .333333, p3 = p - .5;
    
    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)
    
    // Falloff values from the skewed point to each of the tetrahedral points.
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    
    // Assigning four random values to each of the points above. 
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    
    // Further randomizing "d," then combining it with "v" to produce the final random falloff values. 
    // Range [0, 1]
    d = fract(sin(d)*262144.)*v*2.; 
    
    // Reusing "v" to determine the largest, and second largest falloff values. Analogous to distance.
    v.x = max(d.x, d.y), v.y = max(d.z, d.w), v.z = max(min(d.x, d.y), min(d.z, d.w)), v.w = min(v.x, v.y); 
    
    // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
    return  max(v.x, v.y) - max(v.z, v.w);  
    
    // return max(v.x, v.y); // Maximum, or regular value for the regular Voronoi aesthetic.  Range [0, 1].
}



// https://iquilezles.org/articles/voronoilines/
/*
oA oB不需要可以不传
oA 最小距离特征点位置
oB 次小距离特征点位置
edge 为 min_d.y-min_d.x
*/
vec2 voronoi(vec2 uv, out vec2 oA, out vec2 oB){
  
  vec2 uv2 = uv;
  vec2 uvi = floor(uv2);
  vec2 uvf = fract(uv2);

  // x分量代表当前像素距离特征点的最小距离,y代表次小距离
  vec2 min_d = vec2(10.);

  for(int x=-1;x<2;x++){
  for(int y=-1;y<2;y++){
    vec2 nei = vec2(x,y);
    vec2 pos = sin(hash22(uvi+nei)*10.)*.3+.3;
    float d1 = length(nei+pos-uvf);
    /*
    距离小于最小距离,
    次小距离更新为现在的"最小距离"
    最小距离更新

    距离小于次小距离,
    次小距离更新
    */
    if(d1<min_d.x){
      min_d.y = min_d.x;
      min_d.x = d1;
      oA = pos;
    }else if(d1 < min_d.y){
      min_d.y = d1;
      oB = pos;
    }
  }
  }

  return min_d;
}


float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

// 2D 柏林噪音
vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  // a+=T;
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


// 3D 柏林噪音
float hash13(vec3 p3)
{
	  p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 randomGradient(vec3 p){
  float the = hash13(p)*TAU;
  float phi = hash13(p+vec3(3,2,1))*TAU;
  return vec3(sin(the)*cos(phi), sin(the)*sin(phi), cos(the));

  // float z = hash13(p)*2.0 - 1.0;        // 均匀分布在 [-1,1]
  // float a = hash13(p+vec3(3,2,1)) * TAU; 
  // float r = sqrt(1.0 - z*z);
  // return vec3(r*cos(a), r*sin(a), z);
}

float noise(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);

  vec3 g000 = randomGradient(i+vec3(0,0,0));
  vec3 g100 = randomGradient(i+vec3(1,0,0));
  vec3 g010 = randomGradient(i+vec3(0,1,0));
  vec3 g001 = randomGradient(i+vec3(0,0,1));
  vec3 g011 = randomGradient(i+vec3(0,1,1));
  vec3 g101 = randomGradient(i+vec3(1,0,1));
  vec3 g110 = randomGradient(i+vec3(1,1,0));
  vec3 g111 = randomGradient(i+vec3(1,1,1));

  float v000 = dot(g000, f-vec3(0,0,0));
  float v100 = dot(g100, f-vec3(1,0,0));
  float v010 = dot(g010, f-vec3(0,1,0));
  float v001 = dot(g001, f-vec3(0,0,1));
  float v011 = dot(g011, f-vec3(0,1,1));
  float v101 = dot(g101, f-vec3(1,0,1));
  float v110 = dot(g110, f-vec3(1,1,0));
  float v111 = dot(g111, f-vec3(1,1,1));

  // vec3 u = smoothstep(0.,1.,f);
  vec3 u = f*f*f*(f*(f*6.0 - 15.0) + 10.0);


  float mx1 = mix(v000, v100, u.x);
  float mx2 = mix(v010, v110, u.x);
  float mx3 = mix(v001, v101, u.x);
  float mx4 = mix(v011, v111, u.x);
  float my1 = mix(mx1, mx2, u.y);
  float my2 = mix(mx3, mx4, u.y);
  float mz = mix(my1, my2, u.z);
  return mz;
}
