#version 460 core
// Disolución en tinta: máscara de ruido que se come la figura de arriba hacia
// abajo con bordes desflecados. Se usa con ShaderMask (BlendMode.dstIn): el
// alfa de salida decide qué queda de la figura.
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uProgress;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(234.34, 435.345));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int k = 0; k < 4; k++) {
    v += a * noise(p);
    p *= 2.03;
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  // Manchas de tinta más un empuje vertical: lo de arriba se va primero.
  float field = fbm(uv * 6.0) * 0.7 + uv.y * 0.3;
  float p = uProgress * 1.15 - 0.08;
  float a = smoothstep(p, p + 0.07, field);
  fragColor = vec4(a);
}
