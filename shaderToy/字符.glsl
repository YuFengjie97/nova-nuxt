#iChannel0 "file://D:/workspace/nova-nuxt/public/img/texture_char.png"


/*
uv, 连续的uv(0-1)
i, 目标整数索引
texSize, 材质行列所含数字个数(材质尺寸)
*/
float getTexture(vec2 uv, float i, vec2 texSize){
    // 获取目标索引的位置
    vec2 pos = vec2(mod(i, texSize.y), floor(i / texSize.x)) / texSize;
    
    // 获取材质中的目标区域
    float d = texture(iChannel0, uv / 16. - pos).r;
    return d;
}


float random(float x) {
    return fract(sin(x) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - iResolution.xy * 0.5)/iResolution.y;


    
    // 画布尺寸
    float size = 15.;
    uv *= size;
    
    // 对每列进行随机偏移
    float xi = floor(uv.x);
    float offset = mod(xi, floor(100. *random(xi) - 50.)) * iTime * 0.1;
    uv.y += offset;
    

    vec2 uvi = floor(uv);
    vec2 uvf = fract(uv);
    
    
    // 当前uv对应索引
    float i = uvi.y * size + uvi.x;
    
    // 数字材质图片行列所含字符数
    vec2 texSize = vec2(16., 16.);
    
    // 获取随机数字
    float ind = floor(random(uvi.x * uvi.y) * 100. + iTime);
    
    float texNum = getTexture(uvf, ind, texSize);
    
    vec3 col = vec3(0.);
    vec3 green = vec3(0.,1.,0.);
    col += green  * texNum;

    fragColor = vec4(col,1.0);
}