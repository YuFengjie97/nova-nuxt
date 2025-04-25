#version 300 es
precision mediump float;

in vec2 aPosition;
out vec2 fragCoord;

uniform vec2 iResolution;

uniform mat3 uProjectionMatrix;
uniform mat3 uWorldTransformMatrix;
uniform mat3 uTransformMatrix;

void main() {
    mat3 mvp = uProjectionMatrix * uWorldTransformMatrix * uTransformMatrix;
    gl_Position = vec4((mvp * vec3(aPosition, 1.0)).xy, 0.0, 1.0);

    vec2 fc = vec2(aPosition.x, iResolution.y - aPosition.y);
    fragCoord = fc;
}