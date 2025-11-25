
void mainImage( out vec4 O, vec2 I )
{
    float i,d,w,s,n,t=iTime,m=1.;
    vec3 p,k,r = iResolution;
    mat2 R = mat2(cos(sin(t/2.)*.785 +vec4(0,33,11,0)));
    
    for(O*=i; i++<1e2; O += max(sin(vec4(1,2,3,1)+i*.5)*1.3/w,-length(k*k))){
    
        p = vec3((I+I-r.xy)/r.y*d, d-10.);
        
        if(abs(p.x)>6.) break;
        
        p.xz *= R;

        // 镜像
        if(p.y < -6.3) {
            p.y = -p.y-9.;
            m = .5;
        }
        
        k=p;

        // 湍流与噪音
        for(p*=.5,n = .01; n < .2; n += n)
            p.yz += cos(p.xy*.01) - abs(dot(sin(.02*p.z+.03*p.y+2.*t + .3*p/n), p-p+n));
            
        s = length(k.xy)-4.;
        // 形状1 和 形状2 通过p.y来混合
        w = mix(sin(length(ceil(k*4.).z+k)), sin(length(p)-1.), smoothstep(5., 5.5, p.y));
        // w = sin(length(ceil(k*4.).z+k));
        // w =  sin(length(p)-1.);

        // 新形状 和 另一个形状的交集        
        w =.01+.07*abs(max(w,sqrt(s*s+k*k).z-1.5)-i/150.);
        
        d += w;
    }
    
    O = tanh(O*O/1e6)*m;  
}