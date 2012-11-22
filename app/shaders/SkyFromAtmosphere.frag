//#version 110

uniform vec3 v3LightPos;
uniform float fg;
uniform float fg2;
uniform float fExposure;

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
    float fCos = dot(v3LightPos, v3Direction) / length(v3Direction);
    float fCos2 = fCos*fCos;
    gl_FragColor = getRayleighPhase(fCos2) * v4RayleighColor + getMiePhase(fCos, fCos2, fg, fg2) * v4MieColor;
    gl_FragColor.a = max(max(gl_FragColor.r, gl_FragColor.g), gl_FragColor.b);
    gl_FragColor = 1.0 - exp(-fExposure * gl_FragColor);
    
}
