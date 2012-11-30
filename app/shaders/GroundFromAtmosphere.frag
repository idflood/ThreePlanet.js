// Atmospheric scattering shader
//
// Author: Sean O'Neil
//
// Copyright (c) 2004 Sean O'Neil
//
// Based on the blender example

uniform sampler2D tGround;
uniform sampler2D tNight;

uniform float fExposure;

varying vec2 texCoord;
varying vec4 primary_color;
varying vec4 secondary_color;

void main (void)
{
  //gl_FragColor = gl_Color + 0.25 * gl_SecondaryColor;
  vec4 f4Color = primary_color + texture2D(tGround, texCoord) * secondary_color + (texture2D(tNight, texCoord)*(1.0- secondary_color))*0.2;

  gl_FragColor = 1.0 - exp(f4Color * -fExposure);
}
