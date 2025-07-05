// https://www.shadertoy.com/view/w3tGWS

#define N(x,d) abs(dot(cos(x * n), vec3(d))) / n


void mainImage( out vec4 o, in vec2 u )
{
    vec2 R = iResolution.xy;
    u = (u-R/2.)/R.y;

    float d=.002,z, t = iTime;
    vec3  w,p;

    o.rgb *= 0.;
    o.a = 1.;


    for (float i; i<64.; i++){
      p = w = vec3(u * z, z + t);

      // 陆地,使用差集挖去中间的圆形空洞
      d = max(w.y+.4, -(length(p.xy)-3.));
      

      // fbm, N()是cos的简便3D噪音
      for(float n = 1.;n < 8.;n *= 1.42){
        w.y -= N(t+w, .04);
        d += N(p, .13);
      }

      // 水
      float d2 = .002+abs(2.+w.y);

      z += d = min(d*.7, d2);
      o += 3./z;
      
      if(d<0.001) break;
    }

    o = tanh(o/1e2);
}

