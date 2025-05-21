#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/jfa/bufferA.glsl"

#define T(u) Timpl(u, iChannel0, iResolution.xy)
vec4 Timpl(vec2 u, sampler2D smp, vec2 R)
{
  if (u.x < 0. || u.y < 0. || u.x >= R.x || u.y >= R.y) return vec4(1e6);
  if (max(u.x, u.y) < 1.) return vec4(1e6);
  return texelFetch(smp, ivec2(u), 0);
}
#define D distance

// ---------------------------------------------------------------------------------------
//	Created by fenix in 2023
//	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
//  This shader was inspired by MysteryPancake's comment on this shader's fork parent,
//  asking to support interior distances (in other words, an actually *signed* distance
//  field). Fair enough, but it does present an extra challenge. It made the shader
//  sufficiently more complicated that it seemed like posting a new one was warranted.
//
//  The difficulty with interior distances is the same as the problem with supporting
//  erasing: the way jump flood works, each pixel stores the location of its nearest
//  zero-distance cell. When any pixel on the screen disappears, any of the other pixels
//  in the buffer might point to it. This can be solved by having each pixel reset itself
//  if it finds it is pointing to a pixel being drawn on. You can see this happening in
//  the blue interior area as you draw, a chunk of the buffer gets much worse momentarily
//  before fixing itself.
//
//  An extra trick is that not only might our own cell be pointing to an invalidated
//  cell, we might also find an invalidated cell while performing the jump flood. So
//  the jump flood also had to be modified slightly to prevent cells that "refused to
//  be erased".
//
//  The way I did this, there are essentially two different jump floods happening, one
//  on the exterior and one on the interior. It seems like it might be possible to
//  still do just a single jump flood, which keeps track of the closest zero-distance
//  cell both interior and exterior, and record whether we're inside or out in another
//  channel. I tried this briefly, but it was tricky writing the cells when drawing
//  with the mouse, because it's easy to add zero distance cells that you didn't expect.
//
//   * Set the brush size via BRUSH_SIZE in Buffer A
// ---------------------------------------------------------------------------------------

void mainImage( out vec4 O, vec2 u )
{
    O.x = D(T(u).xy, u) - D(T(u).zw, u);

    O = mix( vec4(1), (O.x > 0. ? vec4(0.9,0.6,0.3, 1) : vec4(0.65,0.85,1.0, 1)) // iq's standard SDF distance visualization
	                     * (1. - exp(-6.*abs(O.x * .002)))
	                     * (.8 + .2*cos(O.x * .3)), smoothstep(0., 3.,abs(O.x)) );
                         
    vec2 c = (vec2(sin(iTime * .3), cos(iTime)) * .45 + .5) * iResolution.xy; // circle center
    O = mix(O, vec4(1, 1, 0, 1), smoothstep(3., 0., abs(D(c, u) - D(T(c).xy, c) - D(T(c).zw, c)))); // render circle
}
