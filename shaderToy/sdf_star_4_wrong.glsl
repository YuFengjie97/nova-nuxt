vec2 remap(vec2 p, vec2 in_min, vec2 in_max){
    vec2 out_min = vec2(0.);
    vec2 out_max = vec2(1.);

    vec2 res = (p-in_min)/(in_max-in_min) * (out_max-out_min);
    return clamp(res, out_min, out_max);
}

vec3 getGlow(float dist, float r, float ins, vec3 col){
    float d = pow(r/dist, ins);
    vec3 c = col * d;
    return 1.-exp(-c);
}

float sdf_star4(vec2 uv){
    float r = 0.1;
    float d = length(uv);
    float x = abs(uv.y) + smoothstep(0.1,3.,abs(uv.x));
    float y = abs(uv.x) + smoothstep(0.1,3.,abs(uv.y));
    x*=d*4.;
    y*=d*4.;
    float s = min(d,min(x,y));
    return s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-iResolution.xy*0.5)/iResolution.y;
    
    float t = mod(iTime, 6.);
    vec3 col = vec3(0.);
    
    if(t<3.) {
        float star = sdf_star4(uv);
        vec3 glow = getGlow(star,0.01,4.,vec3(1.,0.,0.));
        col += glow;
    }else{
        // iq
        float d = sdf_star4(uv);
        col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
        col *= 1.0 - exp(-6.0*abs(d));
        col *= 0.8 + 0.2*cos(150.0*d);
        col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.005,abs(d)) );
    }


    fragColor = vec4(col,1.0);
}