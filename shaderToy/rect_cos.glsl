void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    
    uv *= 4.;

    vec3 col = vec3(0.);
    vec3 red = vec3(1.,0.,0.);
    vec3 gre = vec3(0.,1.,0.);
    vec3 blu = vec3(0.,0.,1.);
    
    vec2 u = cos(uv);
    //u = max(u, u.yx);
    float d = length(u);
    float aa = fwidth(d);
    
    float r = .99;    
    float shape = smoothstep(aa+r,r,d);
    col += shape*blu;
    
    for(float i=-2.;i<=2.;i+=0.5){
      float l = cos(uv.x) + (floor(uv.y)+i) - uv.y;
      float ld = smoothstep(0.1,0.,abs(l));
      col += ld*red;

      float l2 = cos(uv.y) + (floor(uv.x)+i) - uv.x;
      float ld2 = smoothstep(0.1,0.,abs(l2));
      col += ld2 * gre;
    }
    

    fragColor = vec4(col,1.0);
}