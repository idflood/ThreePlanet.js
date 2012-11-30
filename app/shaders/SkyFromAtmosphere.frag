// Atmospheric scattering shader
//
// Author: Sean O'Neil
//
// Copyright (c) 2004 Sean O'Neil
//
// Based on the blender example

uniform vec3 v3LightPos;
uniform float fg;
uniform float fg2;
uniform float fExposure;
uniform float fCameraHeight, fOuterRadius, fScaleDepth;

varying vec3 v3Direction;
varying float depth;

varying vec4 primary_color;
varying vec4 secondary_color;

void main (void)
{
  float fCos = dot(v3LightPos, v3Direction) / length(v3Direction);
  float fRayleighPhase = 0.75 * (1.0 + (fCos*fCos));
  float fMiePhase = 1.5 * ((1.0 - fg2) / (2.0 + fg2)) * (1.0 + fCos*fCos) / pow(1.0 + fg2 - 2.0*fg*fCos, 1.5);

  float sun = 2.0*((1.0 - 0.2) / (2.0 + 0.2)) * (1.0 + fCos*fCos) / pow(1.0 + 0.2 - 2.0*(-0.2)*fCos, 1.0);

  vec4 f4Ambient = (sun * depth + (fOuterRadius - fCameraHeight))*vec4(0.05, 0.05, 0.1,1.0);

  vec4 f4Color = (fRayleighPhase * primary_color + fMiePhase * secondary_color)+f4Ambient;
  vec4 HDR = 1.0 - exp(f4Color * -fExposure);
  float nightmult = clamp(max(HDR.x, max(HDR.y, HDR.z))*1.5,0.0,1.0);

  //gl_FragColor = vec4(f4Ambient);
  gl_FragColor = HDR;
  gl_FragColor.a = nightmult+(fOuterRadius - fCameraHeight);
  //gl_FragColor.a = nightmult;
}
