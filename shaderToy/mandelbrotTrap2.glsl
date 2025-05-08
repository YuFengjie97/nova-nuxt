float sdHexagram( in vec2 p, in float r )
{
    const vec4 k = vec4(-0.5,0.8660254038,0.5773502692,1.7320508076);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= 2.0*min(dot(k.yx,p),0.0)*k.yx;
    p -= vec2(clamp(p.x,r*k.z,r*k.w),r);
    return length(p)*sign(p.y);
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdCross( in vec2 p, in vec2 b, float r ) 
{
    p = abs(p); p = (p.y>p.x) ? p.yx : p.xy;
    vec2  q = p - b;
    float k = max(q.y,q.x);
    vec2  w = (k>0.0) ? q : vec2(b.y-p.x,-k);
    return sign(k)*length(max(w,0.0)) + r;
}


float orbitTrap(vec2 z, vec2 trapCenter, float trapRadius) {
    return sdCircle(z - trapCenter, trapRadius);
    // return sdHexagram(z, trapRadius);
    // return sdCross(z, vec2(0.5), trapRadius);
}



void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 R = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * R) / R.y;
    uv *= 2.;
    uv = abs(uv);

    float t = sin(iTime + cos(2.*iTime)) * 0.5 + 0.5;

    // vec2 c = vec2( 0.285, 0.01);// 连通、对称
    // vec2 c = vec2(-0.70176, -0.3842);// 非连通、碎片状
    // vec2 c = vec2( 0.355, 0.355);// 连通花状
    vec2 c = vec2(-0.4, 0.6); // 多旋臂
    

    vec2 z = uv;
    

    float minTrap = 1e20;
    float trapVal;

    for (int i = 0; i < 100; i++) {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;

        // 记录最接近 trap 的值
        trapVal = orbitTrap(z, vec2(0.0), t); // trap: 圆心在原点、半径0.1的圆
        minTrap = min(minTrap, abs(trapVal));

        if (length(z) > 2.0) break;
    }

    // trap 越小颜色越亮
    float brightness = exp(-10. * minTrap);
    vec3 color = sin(vec3(3.,2.,1.)* brightness);

    fragColor = vec4(color, 1.0);
}
