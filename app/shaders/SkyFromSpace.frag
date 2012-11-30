//#version 110

uniform vec3 v3LightPos;
uniform float fg;
uniform float fg2;
uniform float fExposure;

varying vec3 v3Direction;
varying float depth;

varying vec4 v4RayleighColor;
varying vec4 v4MieColor;


varying vec4 primary_color;
varying vec4 secondary_color;


// Mie phase function
float getMiePhase(float fCos, float fCos2, float g, float g2)
{
   return 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos2) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);
}

// Rayleigh phase function
float getRayleighPhase(float fCos2)
{
   //return 0.75 + 0.75 * fCos2;
   return 0.75 * (2.0 + 0.5 * fCos2);

}

void main (void)
{
   float fCos = dot(v3LightPos, v3Direction) / length(v3Direction);

  float fRayleighPhase = 0.75 * (1.0 + (fCos*fCos));
  float fMiePhase = 1.5 * ((1.0 - fg2) / (2.0 + fg2)) * (1.0 + fCos*fCos) / pow(1.0 + fg2 - 2.0*fg*fCos, 1.5);

  float sun = 2.0*((1.0 - 0.2) / (2.0 + 0.2)) * (1.0 + fCos*fCos) / pow(1.0 + 0.2 - 2.0*(-0.2)*fCos, 1.0);

  vec4 f4Ambient = (sun * depth )*vec4(0.05, 0.05, 0.1,1.0);

  vec4 f4Color = (fRayleighPhase * primary_color + fMiePhase * secondary_color)+f4Ambient;
  vec4 HDR = 1.0 - exp(f4Color * -fExposure);
  float nightmult = clamp(max(HDR.x, max(HDR.y, HDR.z))*1.5,0.0,1.0);

  //gl_FragColor = vec4(ambient);
  gl_FragColor = HDR;
  gl_FragColor.a = nightmult;
//gl_FragColor = secondary_color;
  //gl_FragColor.a = 1.0;

   //float fCos2 = fCos*fCos;
   //vec4 color = getRayleighPhase(fCos2) * v4RayleighColor + getMiePhase(fCos, fCos2, fg, fg2) * v4MieColor;
   //color.a = max(max(color.r, color.g), color.b);
   //color = 1.0 - exp(-fExposure * color);

   //gl_FragColor = color;
}

