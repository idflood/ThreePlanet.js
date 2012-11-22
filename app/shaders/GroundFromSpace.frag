//#version 110

uniform float fExposure;

uniform sampler2D tGround;
uniform sampler2D tClouds;
uniform sampler2D tNight;

varying vec4 v4RayleighColor;
varying vec4 v4MieColor;
varying float fLightIntensity;

varying vec2 texCoord;

void main (void)
{
  vec4 v4Diffuse = texture2D(tGround, texCoord);
  vec4 colorNight = texture2D(tNight, texCoord);

  vec4 nightEmit = colorNight * (1.0 - fLightIntensity);
  v4Diffuse = (v4RayleighColor * fLightIntensity + v4Diffuse * v4MieColor * fLightIntensity) * fLightIntensity + nightEmit;

  gl_FragColor = 1.0 - exp(-fExposure * (v4RayleighColor + v4Diffuse * v4MieColor));
  gl_FragColor.a = 1.0;
}
