#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/jfa/bufferA.glsl"


// ---------------------------------------------------------------------------------------
//   XY coordinates hold the location for exterior cells of nearest zero-distance (drawn-on) pixel
//   ZW coordinates hold the location for interior cells of nearest zero-distance (drawn-on) pixel
// ---------------------------------------------------------------------------------------

#define T(u) Timpl(u, iChannel0, iResolution.xy)
vec4 Timpl(vec2 u, sampler2D smp, vec2 R)
{
  if (u.x < 0. || u.y < 0. || u.x >= R.x || u.y >= R.y) return vec4(1e6);
  if (max(u.x, u.y) < 1.) return vec4(1e6);
  return texelFetch(smp, ivec2(u), 0);
}
#define D distance

#define BRUSH_SIZE .05 * R.y

void mainImage( out vec4 O, vec2 u )
{
    vec3 R = iResolution, m = iMouse.xyz;
    
    if (max(u.x, u.y) < 1.)
        O = vec4(0, 0, 0, R.x * R.y); // resolution stored in lower left corner
    else if (iFrame == 0 || // bootstrap
        texelFetch(iChannel0,ivec2(0,0),0).w != R.x * R.y) // detect resolution changes
    {
        O.xy = vec2(1e6);
        O.zw = u;
    }
    else
    {        
        O = T(u);
        if (m.z > 0. && D(m.xy, O.zw) < BRUSH_SIZE) // clear any cells that point to a cell under active mouse
            O.zw = vec2(1e6);
        else
        {
            // search nearby cells for new shorter path
            for (int x = -1; x <= 1; ++x)
            for (int y = -1; y <= 1; ++y)
            {
                vec4 a = T(u + exp2(float(iFrame % 8)) * vec2(x, y));
                O.xy = D(u, a.xy) < D(O.xy, u) ? a.xy : O.xy; // when we find a shorter path, update our root
                if (m.z <= 0. || D(a.zw, m.xy) >= BRUSH_SIZE) // don't let the jump flood grab pixels being drawn on, right as they're resetting themselves
                    O.zw = D(u, a.zw) < D(O.zw, u) ? a.zw : O.zw; // update interior shortest path
            }
        }
        
        // support drawing with mouse
        O = m.z > 0. && D(m.xy, u) < BRUSH_SIZE ? vec4(u.xy, vec2(1e7)) : O;
    }
}
