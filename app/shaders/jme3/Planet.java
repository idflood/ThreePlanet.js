package atmosphere;

import com.jme3.math.FastMath;
import com.jme3.math.Vector3f;

/**
 * This class contains the main parameters used in the shaders.
 *
 * @author jiyarza
 */
public class Planet {
    private int nSamples;           // Number of sample rays to use in integral equation
    private float fSamples;         // float version of the above
    private float Kr;               // Rayleigh scattering constant
    private float KrESun, Kr4PI;    // Kr * ESun, Kr * 4 * PI
    private float Km;               // Mie scattering constant
    private float KmESun, Km4PI;    // Km * ESun, Km * 4 * PI
    private float ESun;             // Sun brightness constant
    private float G;                // The Mie phase asymmetry factor
    private float innerRadius;      // Ground radius (outer radius is always 1.025 * innerRadius)
    private float scale;            // 1 / (outerRadius - innerRadius)
    private float scaleDepth;       // The scale depth (i.e. the altitude at which the atmosphere's average density is found)
    private float scaleOverScaleDepth; // scale / scaleDepth

    private Vector3f wavelength;
    private Vector3f invWavelength4; // 1 / pow(wavelength, 4) for the red, green, and blue channels
    private float exposure;

    private Vector3f position;
    private float rotationSpeed;

    public Planet(float radius, Vector3f pos) {
        innerRadius = radius;
        position = pos;
        defaultValues();
    }

    private void defaultValues() {
        nSamples = 3;

        // values that work well
        Kr = 0.0025f;
        Km = 0.0015f;
        ESun = 10f;
        exposure = 2f;
        wavelength = new Vector3f(0.731f, 0.612f, 0.455f);

        G = -0.990f;
        invWavelength4 = new Vector3f();
        scaleDepth = 0.25f;
        rotationSpeed = 0.0006f;
        updateCalculations();
    }

    /**
     * Call this method after changing parameter values
     */
    public void updateCalculations() {
        scale = 1.0f / ((innerRadius * 1.025f) - innerRadius);
        scaleOverScaleDepth = scale / scaleDepth;
        KrESun = Kr * ESun;
        KmESun = Km * ESun;
        Kr4PI = Kr * 4.0f * FastMath.PI;
        Km4PI = Km * 4.0f * FastMath.PI;

        invWavelength4.x = 1.0f / FastMath.pow(wavelength.x, 4.0f);
        invWavelength4.y = 1.0f / FastMath.pow(wavelength.y, 4.0f);
        invWavelength4.z = 1.0f / FastMath.pow(wavelength.z, 4.0f);

        fSamples = (float) nSamples;
    }

    // customizable values
    public void setRadius(float radius) { this.innerRadius = radius; }
    public void setPosition(Vector3f pos) { position = pos; }
    public void setKr(float Kr) { this.Kr = Kr; }
    public void setKm(float Km) { this.Km = Km; }
    public void setESun(float ESun) { this.ESun = ESun; }
    public void setG(float G) { this.G = G; }
    public void setRed(float w) { wavelength.x = w; }
    public void setGreen(float w) { wavelength.y = w; }
    public void setBlue(float w) { wavelength.z = w; }
    public void setSamples(int n) { nSamples = n; }
    public void setExposure(float f) { exposure = f; }
    public void setRotationSpeed(float speed) { this.rotationSpeed = speed; }
    // Getters
    public float getRadius() { return innerRadius; }
    public int getnSamples() { return nSamples; }
    public float getfSamples() { return fSamples; }
    public float getKr() { return Kr; }
    public float getKrESun() { return KrESun; }
    public float getKr4PI() { return Kr4PI; }
    public float getKm() { return Km; }
    public float getKmESun() { return KmESun; }
    public float getKm4PI() { return Km4PI; }
    public float getESun() { return ESun; }
    public float getG() { return G; }
    public float getInnerRadius() { return innerRadius; }
    public float getOuterRadius() { return innerRadius * 1.025f; }
    public float getScale() { return scale; }
    public float getScaleDepth() { return scaleDepth; }
    public float getScaleOverScaleDepth() { return scaleOverScaleDepth; }
    public Vector3f getWavelength() { return wavelength; }
    public Vector3f getInvWavelength4() { return invWavelength4; }
    public float getExposure() { return exposure; }
    public Vector3f getPosition() { return position; }
    public float getRotationSpeed() { return rotationSpeed; }
}
