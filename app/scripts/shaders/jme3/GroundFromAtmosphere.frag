//#version 110

uniform float fExposure;
uniform sampler2D Diffuse1;
uniform sampler2D Diffuse2;

varying vec4 v4RayleighColor;
varying vec4 v4MieColor;
varying vec2 texCoord;
varying float fLightIntensity;
varying vec2 texCoord2;

void main (void)
{
    vec4 v4Diffuse = mix(texture2D(Diffuse1, texCoord), texture2D(Diffuse2, texCoord2), 0.8);
    gl_FragColor = 1.0 - exp(-fExposure*(v4RayleighColor + v4Diffuse * v4MieColor));
    // gl_FragColor = 1.0 - exp(-fExposure * (v4RayleighColor * fLightIntensity + v4Diffuse * v4MieColor * fLightIntensity) * fLightIntensity);
    // gl_FragColor = 1.0 - exp(-fExposure * (v4RayleighColor + v4Diffuse * v4MieColor));       
    gl_FragColor.a = gl_FragColor.b;    
    
}
