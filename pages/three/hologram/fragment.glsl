uniform vec3 uColor;

varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;
varying vec3 vModelNormal;

void main(){
  vec3 col = vec3(0,0,0);

  vec3 normal = vNormal;

  if(!gl_FrontFacing){
    normal = -normal;
  }

  // float d = length(vUv-.5);
  // d = abs(sin(d*20.));
  // float d = abs(sin(vPosition.y*2.)/2.);
  float d = abs(fract(vPosition.y / .04)-.5);
  // d = smoothstep(.2,.1,d);
  // float glow = pow(.1/d, 2.);
  // float glow = d;


  // col += d * vec3(.4);

  vec3 viewDirection = normalize(vPosition - cameraPosition);

  float fresnel = pow((1.-dot(-viewDirection, normal)), 2.);
  
  fresnel *= smoothstep(.5, 2., fresnel);


  float alpha =  fresnel;


  // col = (sin(vec3(3,2,1) + dot(vUv, vec2(4.1))))*.5+.5;
  col = uColor;
  col *= d;




  gl_FragColor = vec4(col, alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}