mat2 rotate2D(float a){
  float c = cos(a);
  float s = sin(a);
  return mat2(c,-s,s,c);
}