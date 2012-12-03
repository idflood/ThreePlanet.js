package atmosphere;

import com.jme3.app.Application;
import com.jme3.app.state.AppState;
import com.jme3.app.state.AppStateManager;
import com.jme3.light.DirectionalLight;
import com.jme3.material.Material;
import com.jme3.math.Vector3f;
import com.jme3.renderer.RenderManager;
import com.jme3.renderer.queue.RenderQueue.Bucket;
import com.jme3.scene.Node;
import com.jme3.scene.Spatial;
import com.jme3.texture.Texture;
import com.jme3.util.TangentBinormalGenerator;

/**
 *
 * @author jiyarza
 */
public class PlanetRendererState implements AppState {

    private static final String MESH_SPHERE = "Models/Sphere.mesh.j3o";
    private static final String MAT_GROUND_FROM_SPACE ="MatDefs/GroundFromSpace.j3md";
    private static final String MAT_GROUND_FROM_ATMOSPHERE ="MatDefs/GroundFromAtmosphere.j3md";
    private static final String MAT_SKY_FROM_SPACE ="MatDefs/SkyFromSpace.j3md";
    private static final String MAT_SKY_FROM_ATMOSPHERE ="MatDefs/SkyFromAtmosphere.j3md";
    private Planet planet;
    // Ground sphere
    private Spatial ground;
    // Outer atmosphere sphere
    private Spatial atmosphere;
    // Surface texture (diffuse1)
    private Texture t_diffuse1;
    // Surface texture (diffuse2)
    private Texture t_diffuse2;
    // Materials
    private Material mGroundFromSpace, mSkyFromSpace;
    private Material mGroundFromAtmosphere, mSkyFromAtmosphere;
    // time acc for rotation
    private float time;
    private Application prototype;
    private DirectionalLight sun;

    public PlanetRendererState(Planet planet, DirectionalLight sun) {
        this.sun = sun;
        this.planet = planet;
        this.time = 0.0f;
    }

    public void update(float tpf) {
        time += tpf;

        Vector3f cameraLocation = prototype.getCamera().getLocation();
        Vector3f planetToCamera = cameraLocation.subtract(planet.getPosition());
        float cameraHeight = planetToCamera.length();
        Vector3f lightPosNormalized = sun.getDirection();

        // easy collision detection
        float r = planet.getInnerRadius();
        if (cameraHeight < (r + 1.0f)) {
            prototype.getCamera().setLocation(planetToCamera.normalize().mult(r + 1.0f));
        }

        // change speed if necessary
//        if (cameraHeight < (r * 1.025)) {
//            prototype.atmosphericSpeed();
//        } else {
//            prototype.outerSpaceSpeed();
//        }


        // choose correct material according to camera position
        if (cameraHeight > planet.getOuterRadius()) {
            Material mat = mGroundFromSpace;
            mat.setFloat("Time", time);
            mat.setVector3("v3CameraPos", cameraLocation);
            mat.setVector3("v3LightPos", lightPosNormalized);
            mat.setFloat("fCameraHeight2", cameraHeight * cameraHeight);

            mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
            mat.setFloat("fKrESun", planet.getKrESun());
            mat.setFloat("fKmESun", planet.getKmESun());
            mat.setFloat("fKr4PI", planet.getKr4PI());
            mat.setFloat("fKm4PI", planet.getKm4PI());
            mat.setFloat("fExposure", planet.getExposure());
            ground.setMaterial(mGroundFromSpace);

            mat = mSkyFromSpace;
            mat.setVector3("v3CameraPos", cameraLocation);
            mat.setVector3("v3LightPos", lightPosNormalized);
            mat.setFloat("fCameraHeight", cameraHeight);
            mat.setFloat("fCameraHeight2", cameraHeight * cameraHeight);

            mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
            mat.setFloat("fKrESun", planet.getKrESun());
            mat.setFloat("fKmESun", planet.getKmESun());
            mat.setFloat("fKr4PI", planet.getKr4PI());
            mat.setFloat("fKm4PI", planet.getKm4PI());
            mat.setFloat("fg", planet.getG());
            mat.setFloat("fg2", planet.getG() * planet.getG());
            mat.setFloat("fExposure", planet.getExposure());
            atmosphere.setMaterial(mSkyFromSpace);

        } else {
            Material mat = mGroundFromSpace;

            mat.setFloat("Time", time);
            mat.setVector3("v3CameraPos", cameraLocation);
            mat.setVector3("v3LightPos", lightPosNormalized);
            mat.setFloat("fCameraHeight2", cameraHeight * cameraHeight);

            mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
            mat.setFloat("fKrESun", planet.getKrESun());
            mat.setFloat("fKmESun", planet.getKmESun());
            mat.setFloat("fKr4PI", planet.getKr4PI());
            mat.setFloat("fKm4PI", planet.getKm4PI());
            mat.setFloat("fExposure", planet.getExposure());
            ground.setMaterial(mGroundFromSpace);

            mat = mSkyFromAtmosphere;
            mat.setVector3("v3CameraPos", cameraLocation);
            mat.setVector3("v3LightPos", lightPosNormalized);
            mat.setFloat("fCameraHeight", cameraHeight);
            mat.setFloat("fCameraHeight2", cameraHeight * cameraHeight);

            mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
            mat.setFloat("fKrESun", planet.getKrESun());
            mat.setFloat("fKmESun", planet.getKmESun());
            mat.setFloat("fKr4PI", planet.getKr4PI());
            mat.setFloat("fKm4PI", planet.getKm4PI());
            mat.setFloat("fg", planet.getG());
            mat.setFloat("fg2", planet.getG() * planet.getG());
            mat.setFloat("fExposure", planet.getExposure());
            atmosphere.setMaterial(mSkyFromAtmosphere);
        }
    }

    /**
     * Sets planet constant material params for the ground
     * @param mat
     */
    private void setupGroundMaterial(Material mat) {
            mat.setTexture("Diffuse1", t_diffuse1);
            mat.setTexture("Diffuse2", t_diffuse2);
            mat.setFloat("Speed", planet.getRotationSpeed());
            mat.setVector3("v3LightPos", sun.getDirection().normalize());
            mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
            mat.setFloat("fKrESun", planet.getKrESun());
            mat.setFloat("fKmESun", planet.getKmESun());
            mat.setFloat("fOuterRadius", planet.getOuterRadius());
            mat.setFloat("fInnerRadius", planet.getInnerRadius());
            mat.setFloat("fInnerRadius2", planet.getInnerRadius() * planet.getInnerRadius());
            mat.setFloat("fKr4PI", planet.getKr4PI());
            mat.setFloat("fKm4PI", planet.getKm4PI());
            mat.setFloat("fScale", planet.getScale());
            mat.setFloat("fScaleDepth", planet.getScaleDepth());
            mat.setFloat("fScaleOverScaleDepth", planet.getScaleOverScaleDepth());
            mat.setFloat("fSamples", planet.getfSamples());
            mat.setInt("nSamples", planet.getnSamples());
            mat.setFloat("fExposure", planet.getExposure());
    }

    /**
     * Sets planet constant material params for the sky
     * @param mat
     */
    private void setupSkyMaterial(Material mat) {
        mat.setVector3("v3LightPos", sun.getDirection().normalize());
        mat.setVector3("v3InvWavelength", planet.getInvWavelength4());
        mat.setFloat("fKrESun", planet.getKrESun());
        mat.setFloat("fKmESun", planet.getKmESun());
        mat.setFloat("fOuterRadius", planet.getOuterRadius());
        mat.setFloat("fInnerRadius", planet.getInnerRadius());
        mat.setFloat("fOuterRadius2", planet.getOuterRadius() * planet.getOuterRadius());
        mat.setFloat("fInnerRadius2", planet.getInnerRadius() * planet.getInnerRadius());
        mat.setFloat("fKr4PI", planet.getKr4PI());
        mat.setFloat("fKm4PI", planet.getKm4PI());
        mat.setFloat("fScale", planet.getScale());
        mat.setFloat("fScaleDepth", planet.getScaleDepth());
        mat.setFloat("fScaleOverScaleDepth", planet.getScaleOverScaleDepth());
        mat.setFloat("fSamples", planet.getfSamples());
        mat.setInt("nSamples", planet.getnSamples());
        mat.setFloat("fg", planet.getG());
        mat.setFloat("fg2", planet.getG() * planet.getG());
        mat.setFloat("fExposure", planet.getExposure());
    }

    private void createGround() {
        Spatial geom = createSphere();
        geom.scale(planet.getInnerRadius() * 0.25f);
        geom.setLocalTranslation(planet.getPosition());
        geom.setMaterial(mGroundFromSpace);
        TangentBinormalGenerator.generate(geom);
        //geom.updateModelBound();
        ground = geom;
    }

    private void createAtmosphere() {
        Spatial geom = createSphere();
        geom.scale(planet.getOuterRadius() * 0.25f);
        geom.setLocalTranslation(planet.getPosition());
        geom.setQueueBucket(Bucket.Transparent);
        geom.setMaterial(mSkyFromSpace);
        TangentBinormalGenerator.generate(geom);
        //geom.updateModelBound();
        atmosphere = geom;
    }

    private Spatial createSphere() {
        return prototype.getAssetManager().loadModel(MESH_SPHERE);
    }

    public void initialize(AppStateManager stateManager, Application app) {
        this.time = 0.0f;
        this.prototype = app;

        // x2048
        // t_diffuse1 = prototype.getAssetManager().loadTexture("Textures/world.topo.bathy.200404.3x5400x2700.jpg");
        // x1024
        t_diffuse1 = prototype.getAssetManager().loadTexture("Textures/land_ocean_ice_2048.jpg");
        t_diffuse2 = prototype.getAssetManager().loadTexture("Textures/cloud_combined_2048.jpg");

        // Create materials
        mGroundFromSpace = new Material(prototype.getAssetManager(), MAT_GROUND_FROM_SPACE);
        setupGroundMaterial(mGroundFromSpace);
        mSkyFromSpace = new Material(prototype.getAssetManager(), MAT_SKY_FROM_SPACE);
        setupSkyMaterial(mSkyFromSpace);
        mGroundFromAtmosphere = new Material(prototype.getAssetManager(), MAT_GROUND_FROM_ATMOSPHERE);
        setupGroundMaterial(mGroundFromAtmosphere);
        mSkyFromAtmosphere = new Material(prototype.getAssetManager(), MAT_SKY_FROM_ATMOSPHERE);
        setupSkyMaterial(mSkyFromAtmosphere);

        // Create spatials
        createGround();
        createAtmosphere();

        update(0);

        // draw
        Node rootNode=(Node)app.getViewPort().getScenes().get(0);
        rootNode.attachChild(ground);
        rootNode.attachChild(atmosphere);
    }

    public boolean isInitialized() {
        return mSkyFromSpace != null;
    }

    public void setActive(boolean active) {
    }

    public boolean isActive() {
        return true;
    }

    public void stateAttached(AppStateManager stateManager) {
    }

    public void stateDetached(AppStateManager stateManager) {
        ground.removeFromParent();
        atmosphere.removeFromParent();
    }

    public void render(RenderManager rm) {
    }

    public void postRender() {
    }

    public void cleanup() {
    }

    public void setEnabled(boolean active) {
    }

    public boolean isEnabled() {
        return true;
    }
}
