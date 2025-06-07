#define T iTime
#define PI 3.141596
#define S smoothstep

void mainImage( out vec4 O, in vec2 I ){
    vec2 R = iResolution.xy;
    vec2 uv = (I*2.-R)/R.y;
    O.rgb *= 0.;
    O.a = 1.;

    uv*= 10.;
    uv += cos(uv);
    uv -= cos(uv);

    for(float i=0.;i<20.;i++) {
        float a = T*(i)*0.1;
        float r = i*.5;
        vec2 pos = vec2(cos(a),sin(a))*r;
        float d = length(uv-pos);
        d = pow(.2/d,2.);
        O.rgb +=d;
    }
}