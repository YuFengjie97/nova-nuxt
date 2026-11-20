//像素rg 存储粒子速度方向
//     b 生命周期
//     a 某种类似id的特征值

#iChannel0 "./bufferB.glsl"
#iChannel1 "./bufferA.glsl"


vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// vec2 hash22(vec2 p){
//   return sin(p+vec2(.1,.2))*.5+.5;
// }
// float hash12(vec2 p){
//   return sin(dot(p,vec2(.1)))*.5+.5;
// }


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  O.rgb *= 0.;

  if(iFrame<8){
    float life = hash12(I);
    vec2 pos = hash22(I);
    float id = hash12(I);

    O = vec4(pos, life, id);

  }else{
    vec4 particle = texelFetch(iChannel0, ivec2(I), 0);
    vec2 pos = particle.xy;
    float life = particle.z;
    float id = particle.w;
    pos += .001*texture(iChannel1, pos).xy;
    life += .003;

    // 越界&死亡 重置
    if(pos.x < 0. || pos.x > 1. || pos.y < 0. || pos.y > 1. || life > 1.){
      pos = hash22(I+iTime);
      life = 0.;
    }
    O = vec4(pos, life, id);
  }



}