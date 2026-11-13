#version 460 core
// Papel de arroz: grano fino, fibras largas y una viñeta cálida muy leve.
// Se pinta encima del degradado global con opacidad baja (theme.dart).
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uSeed;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21) + uSeed);
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void main() {
  vec2 px = FlutterFragCoord().xy;
  vec2 uv = px / uSize;
  // Grano: ruido de alta frecuencia.
  float grain = hash(floor(px)) - 0.5;
  // Fibras: ruido estirado en diagonal.
  vec2 q = vec2(px.x * 0.9 + px.y * 0.35, px.y * 0.06 - px.x * 0.02);
  float fiber = smoothstep(0.62, 0.95, noise(q * 0.18)) * 0.8;
  // Manchas suaves de pulpa.
  float pulp = noise(px * 0.012) - 0.5;
  // Viñeta cálida en los bordes.
  float vig = smoothstep(0.55, 1.15, length(uv - 0.5) * 1.6);

  float shade = grain * 0.35 + pulp * 0.5 - fiber * 0.25;
  vec3 warm = vec3(0.55, 0.38, 0.18);
  // Oscurece (marrón cálido) o aclara (papel) según el signo.
  float a = clamp(abs(shade) * 0.22 + vig * 0.10, 0.0, 0.25);
  vec3 col = shade < 0.0 || vig > 0.05 ? warm : vec3(1.0, 0.98, 0.93);
  fragColor = vec4(col * a, a);
}
