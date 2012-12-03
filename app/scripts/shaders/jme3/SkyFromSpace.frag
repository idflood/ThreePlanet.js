//#version 110

uniform vec3 m_v3LightPos;
uniform float m_fg;
uniform float m_fg2;
uniform float m_fExposure;

varying vec3 v3Direction;
varying vec4 v4RayleighColor;
varying vec4 v4MieColor;

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
   float fCos = dot(m_v3LightPos, v3Direction) / length(v3Direction);
   float fCos2 = fCos*fCos;
   vec4 color = getRayleighPhase(fCos2) * v4RayleighColor + getMiePhase(fCos, fCos2, m_fg, m_fg2) * v4MieColor;
   color.a = max(max(color.r, color.g), color.b);
   color = 1.0 - exp(-m_fExposure * color);

   gl_FragColor = color;
}

