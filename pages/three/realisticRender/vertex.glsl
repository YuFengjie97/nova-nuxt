void main(){
  vec4 modelPos = modelMatrix * vec4(position, 1.);
  vec4 viewPos = viewMatrix * modelPos;
  vec4 projectionPos = projectionMatrix * viewPos;

  gl_Position = projectionPos;
}