vec2 hash22(vec2 p)
{
    p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)));
    
    //return normalize(-1.0 + 2.0 * fract(sin(p)*43758.5453123));
    return -1.0 + 2.0 * fract(sin(p)*43758.5453123);
}

float snoise(vec2 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    
    vec2 i = floor(p + (p.x + p.y) * K1);
    
    vec2 a = p - (i - (i.x + i.y) * K2);
    vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    vec2 b = a - (o - K2);
    vec2 c = a - (1.0 - 2.0 * K2);
    
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash22(i)), dot(b, hash22(i + o)), dot(c, hash22(i + 1.0)));
    
    return dot(vec3(70.0, 70.0, 70.0), n);
}

float fbm(vec2 p) {
    float f = 0.0;
    p = p * 4.0;

    f += 1.0000 * snoise(p); p = 2.0 * p;
    f += 0.5000 * snoise(p); p = 2.0 * p;
	f += 0.2500 * snoise(p); p = 2.0 * p;
	f += 0.1250 * snoise(p); p = 2.0 * p;
	f += 0.0625 * snoise(p); p = 2.0 * p;
    
    return f;
}

float f1(vec2 p){
  float n = snoise(vec2(p.x, 0.));
  float d = abs(p.y+n);
  return d;
}

float f2(vec2 p){
  float d = f1(p);
  vec2 h = vec2( 0.01, 0.0 );
  vec2 g = vec2( f1(p+h.xy) - f1(p-h.xy),
                f1(p+h.yx) - f1(p-h.yx) )/(2.0*h.x);
  return abs(d) / length(g);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2.0 - iResolution.xy)/iResolution.y;
    
    // float y = snoise(vec2(uv.x, 0.));
    // float width = 0.1;
    // float line = abs(uv.y+y);
    // float g = length(vec2(dFdx(line), dFdy(line)));
    // line = smoothstep(6.*g,0.,line);
    // fragColor = vec4(vec3(line),1.0);

    float d = f2(uv);
    d = smoothstep(0.04,0.,d);
    fragColor = vec4(vec3(d),1);
}