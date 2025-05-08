
float orbitTrap(vec2 z, vec2 trapCenter, float trapRadius) {
    // 返回 z 到 trapCenter 的距离减去 trapRadius
    return length(z - trapCenter) - trapRadius;
}

vec2 hash12(float p) {
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.11369, 0.13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(vec2(p3.x * p3.y, p3.y * p3.z));
}

vec2 catmullRom(vec2 p0, vec2 p1, vec2 p2, vec2 p3, float t) {
    float t2 = t * t;
    float t3 = t2 * t;
    return 0.5 * (
        2.0 * p1 +
        (-p0 + p2) * t +
        (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
        (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
    );
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 R = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * R) / R.y;
    uv *= 3.;

    float T = iTime * .05;
    float t = mod(T, 4.);
    float ti = floor(t);
    float tf = fract(t*.5);

    vec2 c = vec2(0.);
    vec2 c1 = vec2( 0.285, 0.01);// 连通、对称
    vec2 c2 = vec2(-0.70176, -0.3842);// 非连通、碎片状
    vec2 c3 = vec2( 0.355, 0.355);// 连通花状
    vec2 c4 = vec2(-0.4, 0.6); // 多旋臂
    if(ti==0.) {c = catmullRom(c4, c1, c2, c3, tf);}       
    if(ti==1.) {c = catmullRom(c1, c2, c3, c4, tf);}  
    if(ti==2.) {c = catmullRom(c2, c3, c4, c1, tf);}      
    if(ti==3.) {c = catmullRom(c3, c4, c1, c2, tf);}        

    

    vec2 z = uv;
    

    float minTrap = 1e20;
    float trapVal;

    for (int i = 0; i < 100; i++) {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;

        // 记录最接近 trap 的值
        trapVal = orbitTrap(z, vec2(0.0), 0.1 * tf); // trap: 圆心在原点、半径0.1的圆
        minTrap = min(minTrap, abs(trapVal));

        if (length(z) > 2.0) break;
    }

    // trap 越小颜色越亮
    float brightness = exp(-10. * minTrap);
    vec3 color = sin(vec3(3.,2.,1.)* brightness);

    fragColor = vec4(color, 1.0);
}
