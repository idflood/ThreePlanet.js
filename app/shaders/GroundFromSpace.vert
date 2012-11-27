//#version 110
uniform vec3 v3LightPos;            // world space (or direction)
uniform vec3 v3CameraPos;           // The camera's current position (world space)
uniform vec3 v3InvWavelength;       // 1 / pow(wavelength, 4) for the red, green, and blue channels
uniform float fCameraHeight2;       // fCameraHeight^2
uniform float fOuterRadius;         // The outer (atmosphere) radius
uniform float fOuterRadius2;        // fOuterRadius^2
uniform float fInnerRadius;         // The inner (planetary) radius
uniform float fKr4PI;               // Kr * 4 * PI
uniform float fKm4PI;               // Km * 4 * PI
uniform float fKrESun;              // Kr * ESun
uniform float fKmESun;              // Km * ESun
uniform float fScale;               // 1 / (fOuterRadius - fInnerRadius)
uniform float fScaleDepth;          // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
uniform float fScaleOverScaleDepth; // fScale / fScaleDepth
//uniform int nSamples;
const int nSamples = 2;
uniform float fSamples;
uniform float Time;
uniform float Speed;

varying vec2 texCoord;
varying vec4 v4RayleighColor;
varying vec4 v4MieColor;
varying float fLightIntensity;


varying vec4 primary_color;
varying vec4 secondary_color;


float fInvScaleDepth = (1.0 / fScaleDepth);
/*
https://github.com/mrdoob/three.js/issues/1188
http://jmonkeyengine.org/groups/graphics/forum/topic/help-learning-shaders/#post-180570

model to world: g_WorldMatrix => modelMatrix
model to view space: g_WorldViewMatrix => modelViewMatrix
world to view space: g_ViewMatrix => viewMatrix
projection: projectionMatrix
 */

mat4 g_WorldViewProjectionMatrix = projectionMatrix * modelViewMatrix;
mat4 g_WorldMatrix = modelMatrix;


// Returns the near intersection point of a line and a sphere
float getNearIntersection(vec3 v3Pos, vec3 v3Ray, float fDistance2, float fRadius2)
{
  float B = 2.0 * dot(v3Pos, v3Ray);
  float C = fDistance2 - fRadius2;
  float fDet = max(0.0, B*B - 4.0 * C);
  return 0.5 * (-B - sqrt(fDet));
}

float scale(float fCos)
{
  float x = 1.0 - fCos;
  return fScaleDepth * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

void main(void)
{
  vec4 inPosition = vec4(position, 1.0);
  gl_Position = g_WorldViewProjectionMatrix * inPosition;

  // Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere)
  vec3 v3Pos = position.xyz;
  vec3 v3Ray = v3Pos - v3CameraPos;
  float fFar = length(v3Ray);
  v3Ray /= fFar;

  // Calculate the closest intersection of the ray with the outer atmosphere (which is the near point of the ray passing through the atmosphere)
  float B = 2.0 * dot(v3CameraPos, v3Ray);
  float C = fCameraHeight2 - fOuterRadius2;
  float fDet = max(0.0, B*B - 4.0 * C);
  float fNear = 0.5 * (-B - sqrt(fDet));

  // Calculate the ray's starting position, then calculate its scattering offset
  vec3 v3Start = v3CameraPos + v3Ray * fNear;
  fFar -= fNear;
  float fDepth = exp((fInnerRadius - fOuterRadius) / fScaleDepth);
  float fCameraAngle = dot(-v3Ray, v3Pos) / length(v3Pos);
  float fLightAngle = dot(v3LightPos, v3Pos) / length(v3Pos);
  float fCameraScale = scale(fCameraAngle);
  float fLightScale = scale(fLightAngle);
  float fCameraOffset = fDepth*fCameraScale;
  float fTemp = (fLightScale + fCameraScale);

  // Initialize the scattering loop variables
  float fSampleLength = fFar / fSamples;
  float fScaledLength = fSampleLength * fScale;
  vec3 v3SampleRay = v3Ray * fSampleLength;
  vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;

  // Now loop through the sample rays
  vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
  vec3 v3Attenuate;
  for(int i=0; i<nSamples; i++)
  {
    float fHeight = length(v3SamplePoint);
    float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
    float fScatter = fDepth*fTemp - fCameraOffset;
    v3Attenuate = exp(-fScatter * (v3InvWavelength * fKr4PI + fKm4PI));
    v3FrontColor += v3Attenuate * (fDepth * fScaledLength);
    v3SamplePoint += v3SampleRay;
  }

  primary_color = vec4(v3FrontColor * (v3InvWavelength * fKrESun + fKmESun), 1.0);
  primary_color = vec4(v3FrontColor, 1.9);
  secondary_color = vec4(v3Attenuate, 1.0);
  //primary_color = vec4(v3FrontColor * (v3InvWavelength * fKrESun + fKmESun), 1.0);
  //secondary_color = vec4(v3Attenuate, 1.0);

  //v4MieColor = vec4(v3SampleRay, 1.0);
  texCoord  = uv;
}


