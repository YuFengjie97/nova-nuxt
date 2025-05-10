void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    
    uv *= 4.;

    vec3 col = vec3(0.);
    
    float d = length(cos(uv));
    
    float aa = fwidth(d);
    
    float r = .96;    
    float shape = smoothstep(aa+r,r,d);
    col += shape;

    vec3 red = vec3(1.,0.,0.);
    vec3 gre = vec3(0.,1.,0.);
    for(float i=-2.;i<=2.;i++){
      float l = cos(uv.x) + (floor(uv.y)+i) - uv.y;
      float ld = smoothstep(0.1,0.,abs(l));
      col = mix(col, red, ld);

      float l2 = cos(uv.y) + (floor(uv.x)+i) - uv.x;
      float ld2 = smoothstep(0.1,0.,abs(l2));
      col = mix(col, gre, ld2);
    }
    

    fragColor = vec4(col,1.0);
}