require.config({
  shim: {
    'Three':{
      exports: "THREE"
    },
    CopyShader: ['Three'],
    ConvolutionShader: ['Three'],
    VignetteShader: ['Three'],
    FilmShader: ['Three'],
    TrackballControls: ['Three'],
    EffectComposer: ['Three'],
    RenderPass: ['Three'],
    BloomPass: ['Three'],
    FilmPass: ['Three'],
    TexturePass: ['Three'],
    ShaderPass: ['Three'],
    MaskPass: ['Three']
  },

  paths: {
    jquery: 'vendor/jquery.min',
    Three: 'vendor/threejs/build/Three',
    CopyShader: 'vendor/threejs/examples/js/shaders/CopyShader',
    ConvolutionShader: 'vendor/threejs/examples/js/shaders/ConvolutionShader',
    VignetteShader: 'vendor/threejs/examples/js/shaders/VignetteShader',
    FilmShader: 'vendor/threejs/examples/js/shaders/FilmShader',
    TrackballControls: 'vendor/threejs/examples/js/controls/TrackballControls',
    EffectComposer: 'vendor/threejs/examples/js/postprocessing/EffectComposer',
    RenderPass: 'vendor/threejs/examples/js/postprocessing/RenderPass',
    BloomPass: 'vendor/threejs/examples/js/postprocessing/BloomPass',
    FilmPass: 'vendor/threejs/examples/js/postprocessing/FilmPass',
    TexturePass: 'vendor/threejs/examples/js/postprocessing/TexturePass',
    ShaderPass: 'vendor/threejs/examples/js/postprocessing/ShaderPass',
    MaskPass: 'vendor/threejs/examples/js/postprocessing/MaskPass'
  }
});

require(['app'], function() {
  new ThreePlanet.App()
});
