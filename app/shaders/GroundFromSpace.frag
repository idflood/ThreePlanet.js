// Atmospheric scattering shader
//
// Author: Sean O'Neil
//
// Copyright (c) 2004 Sean O'Neil
//
// Based on the blender example

uniform float fExposure;

uniform sampler2D tGround;
uniform sampler2D tClouds;
uniform sampler2D tNight;

varying vec2 texCoord;
varying vec4 primary_color;
varying vec4 secondary_color;

void main (void)
{
  vec4 v4Diffuse = texture2D(tGround, texCoord);
  vec4 colorNight = texture2D(tNight, texCoord);

  vec4 f4Color = primary_color + v4Diffuse * secondary_color + (colorNight*(1.0- secondary_color))*0.2;

  gl_FragColor = 1.0 - exp(f4Color * -fExposure);
}
