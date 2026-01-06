#include ../../../shaderUtils/glsl-noise/simplex/4d.glsl

uniform float uTime;
uniform float uDeltaTime;
uniform sampler2D uParticleDefault;

void main(){
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec4 particle = texture2D(uParticle, uv);

  vec3 pos = particle.xyz;
  float life = particle.w;

  float t = uTime;
  float dt = uDeltaTime;

  if(life >= 1.){
    life = mod(life, 1.);
    pos = texture2D(uParticleDefault, uv).xyz;
  }else{
  
    vec3 flowFieldDir = vec3(
      snoise(vec4(pos+1., t)),
      snoise(vec4(pos+2., t)),
      snoise(vec4(pos+3., t))
    );

    float flowFieldStrength = snoise(vec4(pos+4., t));
    flowFieldStrength = smoothstep(-.4, 1., flowFieldStrength) * 2.;

    pos += flowFieldStrength * flowFieldDir * dt;
  }


  life += 2.1 * dt;

  // gl_FragColor = vec4(uv, 0,1);
  gl_FragColor = vec4(pos, life);

}