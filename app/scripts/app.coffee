define [
  'jquery',
  'vendor/namespace',
  'Three',
  'CopyShader',
  'ConvolutionShader',
  'VignetteShader',
  'FilmShader',
  'TrackballControls',
  'EffectComposer',
  'RenderPass',
  'BloomPass',
  'FilmPass',
  'TexturePass',
  'ShaderPass',
  'MaskPass',
  'CopyShader',
  'objects/Stars',
  'objects/Planet',
  'vendor/dat.gui.min'
],
() ->
  namespace "ThreePlanet",
    App: class App
      constructor: () ->
        @clock = new THREE.Clock()
        @scene = new THREE.Scene()

        @PLANET_POSITION = new THREE.Vector3(0.001, 0.001, 0.001)
        @PLANET_RADIUS = 200.0 #km
        @lightPosition = new THREE.Vector3(0, 0, - @PLANET_RADIUS * 10)
        @LIGHT_DIRECTION = @PLANET_POSITION.clone().subSelf(@lightPosition).normalize()

        # Create the renderer
        @renderer = new THREE.WebGLRenderer( { clearColor: 0x000000, alpha: true, clearAlpha: 1, antialias: true } )

        # Setup the world
        @createCamera()
        @createLights()
        @initRenderer()
        @createWorld()
        @createLensFlare()

        $(window).bind "resize", (e) => @onResize()

        @animate()

        gui = new dat.GUI
          width: 300
          hide: true

        @camera = "space"
        gui.add(@, "camera", ["space", "atmosphere"]).onChange (value) =>
          @currentCamera = switch value
            when "atmosphere" then @camera2
            else @camera1

        basic = gui.addFolder("Basic")
        basic.add(@planet.planetUtil, "exposure", 1.0, 4)
        basic.add(@planet.planetUtil, "innerRadius")
        basic.add(@planet.planetUtil, "outerRadius")

        advanced = gui.addFolder("Advanced")
        advanced.addColor(@planet.planetUtil, "wavelengthColor")
        advanced.add(@planet.planetUtil, "scaleDepth", 0, 2)
        advanced.add(@planet.planetUtil, "Kr", 0, 0.01)
        advanced.add(@planet.planetUtil, "Km", 0, 0.1)
        # dat.gui Issue with negative number (G is negative)
        # http://code.google.com/p/dat-gui/issues/detail?id=23
        #advanced.add(@planet.planetUtil, "G")

        #gui.close()

      createWorld: () =>
        @stars = new ThreePlanet.objects.Stars()
        @scene.add(@stars)

        @planet = new ThreePlanet.objects.Planet(@PLANET_RADIUS, @PLANET_POSITION, @directionalLight, @currentCamera)
        @scene.add(@planet)

        # Skybox
        r = "textures/nightCompressed/"
        urls = [ r + "px.jpg", r + "nx.jpg", r + "py.jpg", r + "ny.jpg", r + "pz.jpg", r + "nz.jpg" ]
        textureCube = THREE.ImageUtils.loadTextureCube( urls )
        shader = THREE.ShaderUtils.lib[ "cube" ]
        shader.uniforms[ "tCube" ].value = textureCube
        material = new THREE.ShaderMaterial
          fragmentShader: shader.fragmentShader
          vertexShader: shader.vertexShader
          uniforms: shader.uniforms
          side: THREE.BackSide
        mesh = new THREE.Mesh( new THREE.CubeGeometry( 10000, 10000, 10000 ), material )
        #@scene.add( mesh )

      updateWorld: (time, delta) =>
        @lightPosition.z = Math.cos(time * 0.05) * (@PLANET_RADIUS * 10)
        @lightPosition.x = Math.sin(time * 0.05) * (@PLANET_RADIUS * 10)
        @lightPosition.y = Math.sin(time * 0.05) * (- @PLANET_RADIUS * 0.5)

        @scene.updateMatrixWorld()
        @planet.update(time, delta)

      createCamera: () =>
        @camera1 = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 0.1, 10000 )
        @scene.add( @camera1 )

        @controls = new THREE.TrackballControls( @camera1, @renderer.domElement )
        @controls.rotateSpeed = 1.0
        @controls.zoomSpeed = 1.4
        @controls.panSpeed = 0.2

        @controls.noZoom = false
        @controls.noPan = false

        @controls.staticMoving = false
        @controls.dynamicDampingFactor = 0.1
        @controls.keys = [ 65, 83, 68 ]

        @camera1.position.set(@PLANET_POSITION.x + @PLANET_RADIUS * 2, @PLANET_POSITION.y, @PLANET_POSITION.z + @PLANET_RADIUS * 2)
        @camera1.position.x = -600
        @camera1.position.z = 0
        @camera1.lookAt(@PLANET_POSITION)

        @camera2 = new THREE.PerspectiveCamera( 80, window.innerWidth / window.innerHeight, 0.1, 10000 )
        @scene.add( @camera2 )
        @camera2.position = new THREE.Vector3(-67.54433193947916, 134.44195702074728, -134.0052727111125)
        @camera2.rotation = new THREE.Vector3(0.2, -0.9, 1.01)

        @currentCamera = @camera1

      createLights: () =>
        @directionalLight = new THREE.DirectionalLight( 0xffffff, 1.15 )
        @directionalLight.position = @lightPosition
        @scene.add( @directionalLight )

      initRenderer: () =>
        # Create html container
        $("body").append("<div id='container'></div>")
        @container = $("#container")[0]

        @renderer.setSize( window.innerWidth, window.innerHeight )
        @renderer.autoClear = false

        # Add the renderer to the dom
        @container.appendChild( @renderer.domElement )

        # Setup post-processing
        @renderModel = new THREE.RenderPass(@scene, @currentCamera)
        @effectBloom = new THREE.BloomPass(0.7)
        @effectFilm = new THREE.FilmPass(0.25, 0.025, 648, false)
        @effectVignette = new THREE.ShaderPass( THREE.VignetteShader )
        @effectVignette.uniforms['darkness'].value = 1.5

        renderTargetParameters = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.ARGBFormat, stencilBuffer: false }
        @renderTarget = new THREE.WebGLRenderTarget( window.innerWidth, window.innerHeight, renderTargetParameters )

        @composer = new THREE.EffectComposer( @renderer, @renderTarget )
        @composer.addPass( @renderModel )
        #@composer.addPass( @effectBloom )
        @composer.addPass( @effectFilm )
        @composer.addPass( @effectVignette )

        # make the last pass render to screen so that we can see something
        @effectVignette.renderToScreen = true

      createLensFlare: () =>
        textureFlare0 = THREE.ImageUtils.loadTexture("textures/lensflare0.jpg")
        textureFlare2 = THREE.ImageUtils.loadTexture( "textures/lensflare2.jpg" )
        textureFlare3 = THREE.ImageUtils.loadTexture( "textures/lensflare3.jpg" )
        flareColor = new THREE.Color( 0xffffff )

        @lensFlare = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending )
        @lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending )

        @lensFlare.position = @lightPosition
        @lensFlare.customUpdateCallback = @updateLensFlare
        @scene.add( @lensFlare )

      animate: () =>
        delta = @clock.getDelta()
        time = @clock.getElapsedTime() * 10

        requestAnimationFrame( @animate )
        if @controls
          @controls.update()

        @updateWorld(time, delta)
        @render(time, delta)


      render: (time, delta) =>
        @renderer.clear()

        if @composer
          @renderModel.camera = @currentCamera
          @planet.camera = @currentCamera
          @composer.render(delta)
        else
          @renderer.render(@scene, @currentCamera)

      onResize: () =>
        width = window.innerWidth
        height = window.innerHeight
        @camera1.aspect = width / height
        @camera2.aspect = @camera1.aspect
        @camera1.updateProjectionMatrix()
        @camera2.updateProjectionMatrix()
        if @controls
          @controls.screen.width = width
          @controls.screen.height = height

        @renderer.setSize( window.innerWidth, window.innerHeight )
        if @composer
          @composer.reset()
