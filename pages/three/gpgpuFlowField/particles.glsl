#include ../../../shaderUtils/glsl-noise/simplex/4d.glsl

uniform sampler2D uPosDefault;
uniform float uTime;
uniform float uDeltaTime;

uniform sampler2D uTexNoise;

float noise(vec2 p){
  return texture2D(uTexNoise, fract(p)).r * 2. - 1.;
}

void main(){
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 particle = texture2D(uPosTex, uv);

  vec3 pos = particle.xyz;
  float life = particle.w;

  float t = uTime;
  float dt = uDeltaTime;

  if(life >= 1.){
    // life = 0.;
    /**
    切换标签页后,当前页面休眠(texture不再绘制),但是life还在累加(gpu-glsl不再绘制,但是cpu-js(gpgpu乒乓计算+delta传值)还在继续计算)
    终于所有粒子的life都大于1,(有的22.422, 有的 76.97, 43.24.....)
    再次切回标签页,直接life=0.回到了全部粒子具有相同生命周期的状态
    使用mod / fract,取小数点后的值,可以继续保留不同的生命周期
    */
    life = mod(life, 1.);
    pos = texture2D(uPosDefault, uv).xyz;
  }else{


    // flowField 方向
    vec3 flowField = vec3(
      snoise(vec4(pos + 1., t*1.1)),
      snoise(vec4(pos + 2., t*1.1)),
      snoise(vec4(pos + 3., t*1.1))
    );
    flowField = normalize(flowField);

    // vec3 flowField = vec3(
    //   noise(vec2((pos.yz + vec2(.1, .4))*2.1 + t*1.1)),
    //   noise(vec2((pos.xz + vec2(.2, .5))*2.1 + t*1.1)),
    //   noise(vec2((pos.xy + vec2(.3, .6))*2.1 + t*1.1))
    // );
    // flowField = normalize(flowField);


    // flowField 强度
    float flowStrength = snoise(vec4(pos*.1, t*.7+1.));
    flowStrength = smoothstep(-.5,1.,flowStrength);

    pos += flowStrength * flowField * 8. * dt;

    life += 2. * dt;
  }


  gl_FragColor = vec4(pos, life);
}