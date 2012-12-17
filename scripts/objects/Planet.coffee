define [
  'Three',
  'jquery',
  'text!shaders/SkyFromSpace.vert',
  'text!shaders/SkyFromSpace.frag',
  'text!shaders/SkyFromAtmosphere.vert',
  'text!shaders/SkyFromAtmosphere.frag',
  'text!shaders/GroundFromSpace.vert',
  'text!shaders/GroundFromSpace.frag',
  'text!shaders/GroundFromAtmosphere.vert',
  'text!shaders/GroundFromAtmosphere.frag',
  'jquery',
  'vendor/namespace',
], (_, Backbone,
  SkyFromSpaceVert, SkyFromSpaceFrag,
  SkyFromAtmosphereVert, SkyFromAtmosphereFrag,
  GroundFromSpaceVert, GroundFromSpaceFrag,
  GroundFromAtmosphereVert, GroundFromAtmosphereFrag) ->
  ## Planet

  namespace "ThreePlanet.objects",
    settings:
      postprocessing: true
      backgroundColor: 0x000000

    PlanetShaderUtil: class PlanetShaderUtil
      constructor: (@innerRadius, @position) ->
        @nSamples = 2     # Number of sample rays to use in integral equation
        @Kr = 0.0025      # Rayleigh scattering constant
        @Km = 0.0015      # Mie scattering constant
        @ESun = 15.0      # Sun brightness constant
        @exposure = 2.0
        @wavelength = new THREE.Vector3()
        @wavelengthColor = [165, 145, 121]
        @G = -0.99
        @invWavelength4 = new THREE.Vector3()
        @scaleDepth = 0.25
        @outerRadius = @innerRadius * 1.025
        @updateCalculations()

      updateCalculations: () =>
        @scale = 1.0 / (@outerRadius - @innerRadius)
        @scaleOverScaleDepth = @scale / @scaleDepth
        @KrESun = @Kr * @ESun
        @KmESun = @Km * @ESun
        @Kr4PI = @Kr * 4.0 * Math.PI
        @Km4PI = @Km * 4.0 * Math.PI

        @wavelength.x = @wavelengthColor[0] / 255
        @wavelength.y = @wavelengthColor[1] / 255
        @wavelength.z = @wavelengthColor[2] / 255

        @invWavelength4.x = 1.0 / Math.pow(@wavelength.x, 4.0)
        @invWavelength4.y = 1.0 / Math.pow(@wavelength.y, 4.0)
        @invWavelength4.z = 1.0 / Math.pow(@wavelength.z, 4.0)

    Planet: class Planet extends THREE.Object3D
      constructor: (@radius, @pos, @sun, @camera) ->
        super

        @planetUtil = new ThreePlanet.objects.PlanetShaderUtil(@radius, @pos)

        # create 2 geometries since they will have different buffers
        details = 128
        @sphere = new THREE.SphereGeometry( 1, details * 2, details)
        @sphere.computeTangents()
        @sphere2 = new THREE.SphereGeometry( 1, details * 2, details )

        @createBaseUniforms()
        @createShaderSkyFromSpace()
        @createShaderGroundFromSpace()
        @createShaderSkyFromAtmosphere()
        @createShaderGroundFromAtmosphere()

        @mSkyFromSpace.blending = THREE.AdditiveAlphaBlending
        @mSkyFromAtmosphere.blending = THREE.AdditiveAlphaBlending

        @atmosphere = new THREE.Mesh( @sphere2, @mSkyFromSpace )
        @atmosphere.scale.set(@planetUtil.outerRadius, @planetUtil.outerRadius, @planetUtil.outerRadius)
        @add(@atmosphere)

        @ground = new THREE.Mesh( @sphere, @mGroundFromSpace )
        @ground.scale.set(@planetUtil.innerRadius, @planetUtil.innerRadius, @planetUtil.innerRadius)
        @add(@ground)

        #@createClouds()
        return

      createClouds: () =>
        details = 42
        sphereClouds = new THREE.SphereGeometry( 1, details * 2, details )
        cloudsTexture = THREE.ImageUtils.loadTexture("textures/earth_clouds_1024.png")
        materialClouds = new THREE.MeshLambertMaterial( { color: 0xffffff, map: cloudsTexture, transparent:true, depthWrite: false } )
        @meshClouds = new THREE.Mesh( sphereClouds, materialClouds )
        cloudsRadius = @planetUtil.outerRadius - 2.0
        @meshClouds.scale.set(cloudsRadius, cloudsRadius, cloudsRadius)
        @meshClouds.doubleSided = false
        @add(@meshClouds)

      update: (time, delta) =>
        @atmosphere.scale.set(@planetUtil.outerRadius, @planetUtil.outerRadius, @planetUtil.outerRadius)
        @ground.scale.set(@planetUtil.innerRadius, @planetUtil.innerRadius, @planetUtil.innerRadius)

        @planetUtil.updateCalculations()

        @cameraDistance = @pos.distanceTo(@camera.position)
        @cameraDistance2 = @cameraDistance * @cameraDistance
        lightDistance = @pos.distanceTo(@sun.position)
        @lightpos = @sun.position.clone().divideScalar(lightDistance)

        planetToCamera = new THREE.Vector3().sub(@camera.position, @position)
        r = @planetUtil.innerRadius;
        if @cameraDistance < r + 1.0
            @camera.position = planetToCamera.normalize().multiplyScalar(r + 1.0)

        if @meshClouds
          @meshClouds.rotation.y = time * 0.002

        if @cameraDistance > @planetUtil.outerRadius
          @atmosphere.material = @mSkyFromSpace
          @ground.material = @mGroundFromSpace
          #@atmosphere.material = @mSkyFromAtmosphere
        else
          @atmosphere.material = @mSkyFromAtmosphere
          @ground.material = @mGroundFromAtmosphere
          #console.log "atmo"

        @updateCommonUniforms(@mSkyFromSpace)
        @updateCommonUniforms(@mSkyFromAtmosphere)
        @updateCommonUniforms(@mGroundFromSpace)
        @updateCommonUniforms(@mGroundFromAtmosphere)

      updateCommonUniforms: (shader) =>
        shader.uniforms.v3LightPos.value = @lightpos
        # Need to pass the camera position since three.js already pass it with matrixWorld applied
        # # var position = camera.matrixWorld.getPosition();
        # # _gl.uniform3f( p_uniforms.cameraPosition, position.x, position.y, position.z );
        shader.uniforms.v3CameraPos.value = @camera.position
        shader.uniforms.fCameraHeight.value = @cameraDistance
        shader.uniforms.fCameraHeight2.value = @cameraDistance2

        shader.uniforms.fExposure.value = @planetUtil.exposure
        shader.uniforms.fKrESun.value = @planetUtil.KrESun
        shader.uniforms.fKmESun.value = @planetUtil.KmESun
        shader.uniforms.v3InvWavelength.value = @planetUtil.invWavelength4

        shader.uniforms.fKr4PI.value = @planetUtil.Kr4PI
        shader.uniforms.fKm4PI.value = @planetUtil.Km4PI

        shader.uniforms.fScale.value = @planetUtil.scale
        shader.uniforms.fScaleDepth.value = @planetUtil.scaleDepth
        shader.uniforms.fScaleOverScaleDepth.value = @planetUtil.scaleOverScaleDepth

        shader.uniforms.fOuterRadius.value = @planetUtil.outerRadius
        shader.uniforms.fInnerRadius.value = @planetUtil.innerRadius
        shader.uniforms.fOuterRadius2.value = @planetUtil.outerRadius * @planetUtil.outerRadius

        shader.uniforms.fg.value = @planetUtil.G
        shader.uniforms.fg2.value = @planetUtil.G * @planetUtil.G

      createBaseUniforms: () =>
        @baseUniforms =
          v3CameraPos:
            type: 'v3'
            value: @camera.position
          fCameraHeight:
            type: 'f'
            value: 206.0
          fCameraHeight2:
            type: 'f'
            value: 32000.0
          v3LightPos:
            type: 'v3'
            value: @sun.position.clone().normalize()
          fg:
            type: 'f'
            value: @planetUtil.G
          fg2:
            type: 'f'
            value: @planetUtil.G * @planetUtil.G
          fExposure:
            type: 'f'
            value: @planetUtil.exposure
          fScaleDepth:
            type: 'f'
            value: @planetUtil.scaleDepth
          fScaleOverScaleDepth:
            type: 'f'
            value: @planetUtil.scaleOverScaleDepth
          fSamples:
            type: 'f'
            value: @planetUtil.nSamples
          v3InvWavelength:
            type: 'v3'
            value: @planetUtil.invWavelength4
          fKrESun:
            type: 'f'
            value: @planetUtil.KrESun
          fKmESun:
            type: 'f'
            value: @planetUtil.KmESun
          fOuterRadius:
            type: 'f'
            value: @planetUtil.outerRadius
          fInnerRadius:
            type: 'f'
            value: @planetUtil.innerRadius
          fOuterRadius2:
            type: 'f'
            value: @planetUtil.outerRadius * @planetUtil.outerRadius
          fKr4PI:
            type: 'f'
            value: @planetUtil.Kr4PI
          fKm4PI:
            type: 'f'
            value: @planetUtil.Km4PI
          fScale:
            type: 'f'
            value: @planetUtil.scale

      createShaderSkyFromAtmosphere: () =>
        uniformsBase = THREE.UniformsUtils.clone(@baseUniforms)

        @mSkyFromAtmosphere = new THREE.ShaderMaterial
          uniforms: uniformsBase
          vertexShader: SkyFromAtmosphereVert
          fragmentShader: SkyFromAtmosphereFrag
          side: THREE.BackSide
          shading: THREE.SmoothShading
          depthWrite: false
          transparent: true

      createShaderSkyFromSpace: () =>
        uniformsBase = THREE.UniformsUtils.clone(@baseUniforms)

        @mSkyFromSpace = new THREE.ShaderMaterial
          uniforms: uniformsBase
          vertexShader: SkyFromSpaceVert
          fragmentShader: SkyFromSpaceFrag
          side: THREE.BackSide
          shading: THREE.SmoothShading
          depthWrite: false
          transparent: true

      createShaderGroundFromSpace: () =>
        planetTexture = THREE.ImageUtils.loadTexture("textures/earth_atmos_2048.jpg")
        nightTexture = THREE.ImageUtils.loadTexture("textures/earthnight.jpg")
        bumpTexture = THREE.ImageUtils.loadTexture("textures/earthbump.png")
        #@cloudsTexture = @planetTexture
        uniformsBase = THREE.UniformsUtils.clone(@baseUniforms)

        uniformsGround =
          tGround:
            type: 't'
            value: planetTexture
          tNight:
            type: 't'
            value: nightTexture
          tBump:
            type: 't'
            value: bumpTexture

        $.extend(uniformsBase, uniformsGround)
        @mGroundFromSpace = new THREE.ShaderMaterial
          uniforms: uniformsBase
          vertexShader: GroundFromSpaceVert
          fragmentShader: GroundFromSpaceFrag
          shading: THREE.SmoothShading

      createShaderGroundFromAtmosphere: () =>
        planetTexture = THREE.ImageUtils.loadTexture("textures/earth_atmos_2048.jpg")
        nightTexture = THREE.ImageUtils.loadTexture("textures/earthnight.jpg")
        #bumpTexture = THREE.ImageUtils.loadTexture("textures/earthbump.png")
        #@cloudsTexture = @planetTexture
        uniformsBase = THREE.UniformsUtils.clone(@baseUniforms)

        uniformsGround =
          tGround:
            type: 't'
            value: planetTexture
          tNight:
            type: 't'
            value: nightTexture

        $.extend(uniformsBase, uniformsGround)
        @mGroundFromAtmosphere = new THREE.ShaderMaterial
          uniforms: uniformsBase
          vertexShader: GroundFromAtmosphereVert
          fragmentShader: GroundFromAtmosphereFrag
          shading: THREE.SmoothShading
