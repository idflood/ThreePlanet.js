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
    Three: '../components/threejs/build/Three',
    CopyShader: '../components/threejs/examples/js/shaders/CopyShader',
    ConvolutionShader: '../components/threejs/examples/js/shaders/ConvolutionShader',
    VignetteShader: '../components/threejs/examples/js/shaders/VignetteShader',
    FilmShader: '../components/threejs/examples/js/shaders/FilmShader',
    TrackballControls: '../components/threejs/examples/js/controls/TrackballControls',
    EffectComposer: '../components/threejs/examples/js/postprocessing/EffectComposer',
    RenderPass: '../components/threejs/examples/js/postprocessing/RenderPass',
    BloomPass: '../components/threejs/examples/js/postprocessing/BloomPass',
    FilmPass: '../components/threejs/examples/js/postprocessing/FilmPass',
    TexturePass: '../components/threejs/examples/js/postprocessing/TexturePass',
    ShaderPass: '../components/threejs/examples/js/postprocessing/ShaderPass',
    MaskPass: '../components/threejs/examples/js/postprocessing/MaskPass'
  }
});

require(['app'], function() {
  new ThreePlanet.App()
});
