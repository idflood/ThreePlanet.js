//#version 110

//uniform mat4 g_WorldViewProjectionMatrix;
//uniform mat4 g_WorldMatrix;
//uniform vec3 v3CameraPos;	// The camera's current position
uniform vec3 v3LightPos;	// The direction vector to the light source
uniform vec3 v3InvWavelength;	// 1 / pow(wavelength, 4) for the red, green, and blue channels
uniform float fCameraHeight;	// The camera's current height
uniform float fCameraHeight2;	// fCameraHeight^2
uniform float fOuterRadius;	// The outer (atmosphere) radius
uniform float fOuterRadius2;	// fOuterRadius^2
uniform float fInnerRadius;	// The inner (planetary) radius
uniform float fInnerRadius2;	// fInnerRadius^2
uniform float fKrESun;		// Kr * ESun
uniform float fKmESun;		// Km * ESun
uniform float fKr4PI;		// Kr * 4 * PI
uniform float fKm4PI;		// Km * 4 * PI
uniform float fScale;		// 1 / (fOuterRadius - fInnerRadius)
uniform float fScaleDepth;	// The scale depth (i.e. the altitude at which the atmosphere's average density is found)
uniform float fScaleOverScaleDepth; // fScale / fScaleDepth
//uniform int nSamples;
uniform float fSamples;
//attribute vec4 inPosition;
varying vec3 v3Direction;
varying vec4 v4RayleighColor;
varying vec4 v4MieColor;

mat4 g_WorldMatrix = modelViewMatrix;
mat4 g_WorldViewProjectionMatrix = projectionMatrix * modelViewMatrix;

// assign as constant since "Loop index cannot be compared with non-constant expression"
const int nSamples = 3;

float scale(float fCos)
{
	float x = 1.0 - fCos;
	return fScaleDepth * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

void main(void)
{
  vec4 inPosition = vec4(position, 1.0);
  /*mat4 g_WorldMatrix = modelMatrix;
  g_WorldMatrix = viewMatrix;
  g_WorldMatrix = modelViewMatrix;
  mat4 g_WorldViewProjectionMatrix = projectionMatrix * modelViewMatrix;
  gl_Position = g_WorldViewProjectionMatrix * inPosition;*/

  // Get the ray from the camera to the vertex, and its length (which is the far point of the ray passing through the atmosphere)
	vec3 v3Pos = vec3(g_WorldMatrix * inPosition);
	vec3 v3Ray = v3Pos - cameraPosition;
	float fFar = length(v3Ray);
	v3Ray /= fFar;

	// Calculate the ray's starting position, then calculate its scattering offset
	vec3 v3Start = cameraPosition;
	float fHeight = length(v3Start);
	float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fCameraHeight));
	float fStartAngle = dot(v3Ray, v3Start) / fHeight;
	float fStartOffset = fDepth*scale(fStartAngle);

	// Initialize the scattering loop variables
	float fSampleLength = fFar / fSamples;
	float fScaledLength = fSampleLength * fScale;
	vec3 v3SampleRay = v3Ray * fSampleLength;
	vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;

	// Now loop through the sample rays
	vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
	for(int i=0; i<nSamples; i++)
	{
		float fHeight = length(v3SamplePoint);
		float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
		float fLightAngle = dot(v3LightPos, v3SamplePoint) / fHeight;
		float fCameraAngle = dot(v3Ray, v3SamplePoint) / fHeight;
		float fScatter = (fStartOffset + fDepth*(scale(fLightAngle) - scale(fCameraAngle)));
		vec3 v3Attenuate = exp(-fScatter * (v3InvWavelength * fKr4PI + fKm4PI));
		v3FrontColor += v3Attenuate * (fDepth * fScaledLength);
		v3SamplePoint += v3SampleRay;
	}

        // The "sun" factor brightens the atmosphere trying to cover the starfield
        //float sun = 0.90 + 2.0 * exp(-pow(fHeight,5.0)/pow(fOuterRadius,5.0));
        float sun = 1.0 + 6.50 * exp(-fHeight*fHeight/fOuterRadius*fOuterRadius);

	// Finally, scale the Mie and Rayleigh colors and set up the varying variables for the pixel shader
        v4MieColor = vec4(v3FrontColor * fKmESun, 1.0);
        v4RayleighColor = vec4(v3FrontColor * (v3InvWavelength * fKrESun * sun), 1.0);
	v3Direction = cameraPosition - v3Pos;
}
