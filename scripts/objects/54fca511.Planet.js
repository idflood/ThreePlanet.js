(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['Three', 'jquery', 'text!shaders/SkyFromSpace.vert', 'text!shaders/SkyFromSpace.frag', 'text!shaders/SkyFromAtmosphere.vert', 'text!shaders/SkyFromAtmosphere.frag', 'text!shaders/GroundFromSpace.vert', 'text!shaders/GroundFromSpace.frag', 'text!shaders/GroundFromAtmosphere.vert', 'text!shaders/GroundFromAtmosphere.frag', 'jquery', 'vendor/namespace'], function(_, Backbone, SkyFromSpaceVert, SkyFromSpaceFrag, SkyFromAtmosphereVert, SkyFromAtmosphereFrag, GroundFromSpaceVert, GroundFromSpaceFrag, GroundFromAtmosphereVert, GroundFromAtmosphereFrag) {
    var Planet, PlanetShaderUtil;
    return namespace("ThreePlanet.objects", {
      settings: {
        postprocessing: true,
        backgroundColor: 0x000000
      },
      PlanetShaderUtil: PlanetShaderUtil = (function() {

        function PlanetShaderUtil(innerRadius, position) {
          this.innerRadius = innerRadius;
          this.position = position;
          this.updateCalculations = __bind(this.updateCalculations, this);

          this.nSamples = 2;
          this.Kr = 0.0025;
          this.Km = 0.0015;
          this.ESun = 15.0;
          this.exposure = 2.0;
          this.wavelength = new THREE.Vector3();
          this.wavelengthColor = [165, 145, 121];
          this.G = -0.99;
          this.invWavelength4 = new THREE.Vector3();
          this.scaleDepth = 0.25;
          this.outerRadius = this.innerRadius * 1.025;
          this.updateCalculations();
        }

        PlanetShaderUtil.prototype.updateCalculations = function() {
          this.scale = 1.0 / (this.outerRadius - this.innerRadius);
          this.scaleOverScaleDepth = this.scale / this.scaleDepth;
          this.KrESun = this.Kr * this.ESun;
          this.KmESun = this.Km * this.ESun;
          this.Kr4PI = this.Kr * 4.0 * Math.PI;
          this.Km4PI = this.Km * 4.0 * Math.PI;
          this.wavelength.x = this.wavelengthColor[0] / 255;
          this.wavelength.y = this.wavelengthColor[1] / 255;
          this.wavelength.z = this.wavelengthColor[2] / 255;
          this.invWavelength4.x = 1.0 / Math.pow(this.wavelength.x, 4.0);
          this.invWavelength4.y = 1.0 / Math.pow(this.wavelength.y, 4.0);
          return this.invWavelength4.z = 1.0 / Math.pow(this.wavelength.z, 4.0);
        };

        return PlanetShaderUtil;

      })(),
      Planet: Planet = (function(_super) {

        __extends(Planet, _super);

        function Planet(radius, pos, sun, camera) {
          var details;
          this.radius = radius;
          this.pos = pos;
          this.sun = sun;
          this.camera = camera;
          this.createShaderGroundFromAtmosphere = __bind(this.createShaderGroundFromAtmosphere, this);

          this.createShaderGroundFromSpace = __bind(this.createShaderGroundFromSpace, this);

          this.createShaderSkyFromSpace = __bind(this.createShaderSkyFromSpace, this);

          this.createShaderSkyFromAtmosphere = __bind(this.createShaderSkyFromAtmosphere, this);

          this.createBaseUniforms = __bind(this.createBaseUniforms, this);

          this.updateCommonUniforms = __bind(this.updateCommonUniforms, this);

          this.update = __bind(this.update, this);

          this.createClouds = __bind(this.createClouds, this);

          Planet.__super__.constructor.apply(this, arguments);
          this.planetUtil = new ThreePlanet.objects.PlanetShaderUtil(this.radius, this.pos);
          details = 128;
          this.sphere = new THREE.SphereGeometry(1, details * 2, details);
          this.sphere.computeTangents();
          this.sphere2 = new THREE.SphereGeometry(1, details * 2, details);
          this.createBaseUniforms();
          this.createShaderSkyFromSpace();
          this.createShaderGroundFromSpace();
          this.createShaderSkyFromAtmosphere();
          this.createShaderGroundFromAtmosphere();
          this.mSkyFromSpace.blending = THREE.AdditiveAlphaBlending;
          this.mSkyFromAtmosphere.blending = THREE.AdditiveAlphaBlending;
          this.atmosphere = new THREE.Mesh(this.sphere2, this.mSkyFromSpace);
          this.atmosphere.scale.set(this.planetUtil.outerRadius, this.planetUtil.outerRadius, this.planetUtil.outerRadius);
          this.add(this.atmosphere);
          this.ground = new THREE.Mesh(this.sphere, this.mGroundFromSpace);
          this.ground.scale.set(this.planetUtil.innerRadius, this.planetUtil.innerRadius, this.planetUtil.innerRadius);
          this.add(this.ground);
          return;
        }

        Planet.prototype.createClouds = function() {
          var cloudsRadius, cloudsTexture, details, materialClouds, sphereClouds;
          details = 42;
          sphereClouds = new THREE.SphereGeometry(1, details * 2, details);
          cloudsTexture = THREE.ImageUtils.loadTexture("textures/earth_clouds_1024.png");
          materialClouds = new THREE.MeshLambertMaterial({
            color: 0xffffff,
            map: cloudsTexture,
            transparent: true,
            depthWrite: false
          });
          this.meshClouds = new THREE.Mesh(sphereClouds, materialClouds);
          cloudsRadius = this.planetUtil.outerRadius - 2.0;
          this.meshClouds.scale.set(cloudsRadius, cloudsRadius, cloudsRadius);
          this.meshClouds.doubleSided = false;
          return this.add(this.meshClouds);
        };

        Planet.prototype.update = function(time, delta) {
          var lightDistance, planetToCamera, r;
          this.atmosphere.scale.set(this.planetUtil.outerRadius, this.planetUtil.outerRadius, this.planetUtil.outerRadius);
          this.ground.scale.set(this.planetUtil.innerRadius, this.planetUtil.innerRadius, this.planetUtil.innerRadius);
          this.planetUtil.updateCalculations();
          this.cameraDistance = this.pos.distanceTo(this.camera.position);
          this.cameraDistance2 = this.cameraDistance * this.cameraDistance;
          lightDistance = this.pos.distanceTo(this.sun.position);
          this.lightpos = this.sun.position.clone().divideScalar(lightDistance);
          planetToCamera = new THREE.Vector3().sub(this.camera.position, this.position);
          r = this.planetUtil.innerRadius;
          if (this.cameraDistance < r + 1.0) {
            this.camera.position = planetToCamera.normalize().multiplyScalar(r + 1.0);
          }
          if (this.meshClouds) {
            this.meshClouds.rotation.y = time * 0.002;
          }
          if (this.cameraDistance > this.planetUtil.outerRadius) {
            this.atmosphere.material = this.mSkyFromSpace;
            this.ground.material = this.mGroundFromSpace;
          } else {
            this.atmosphere.material = this.mSkyFromAtmosphere;
            this.ground.material = this.mGroundFromAtmosphere;
          }
          this.updateCommonUniforms(this.mSkyFromSpace);
          this.updateCommonUniforms(this.mSkyFromAtmosphere);
          this.updateCommonUniforms(this.mGroundFromSpace);
          return this.updateCommonUniforms(this.mGroundFromAtmosphere);
        };

        Planet.prototype.updateCommonUniforms = function(shader) {
          shader.uniforms.v3LightPos.value = this.lightpos;
          shader.uniforms.v3CameraPos.value = this.camera.position;
          shader.uniforms.fCameraHeight.value = this.cameraDistance;
          shader.uniforms.fCameraHeight2.value = this.cameraDistance2;
          shader.uniforms.fExposure.value = this.planetUtil.exposure;
          shader.uniforms.fKrESun.value = this.planetUtil.KrESun;
          shader.uniforms.fKmESun.value = this.planetUtil.KmESun;
          shader.uniforms.v3InvWavelength.value = this.planetUtil.invWavelength4;
          shader.uniforms.fKr4PI.value = this.planetUtil.Kr4PI;
          shader.uniforms.fKm4PI.value = this.planetUtil.Km4PI;
          shader.uniforms.fScale.value = this.planetUtil.scale;
          shader.uniforms.fScaleDepth.value = this.planetUtil.scaleDepth;
          shader.uniforms.fScaleOverScaleDepth.value = this.planetUtil.scaleOverScaleDepth;
          shader.uniforms.fOuterRadius.value = this.planetUtil.outerRadius;
          shader.uniforms.fInnerRadius.value = this.planetUtil.innerRadius;
          shader.uniforms.fOuterRadius2.value = this.planetUtil.outerRadius * this.planetUtil.outerRadius;
          shader.uniforms.fg.value = this.planetUtil.G;
          return shader.uniforms.fg2.value = this.planetUtil.G * this.planetUtil.G;
        };

        Planet.prototype.createBaseUniforms = function() {
          return this.baseUniforms = {
            v3CameraPos: {
              type: 'v3',
              value: this.camera.position
            },
            fCameraHeight: {
              type: 'f',
              value: 206.0
            },
            fCameraHeight2: {
              type: 'f',
              value: 32000.0
            },
            v3LightPos: {
              type: 'v3',
              value: this.sun.position.clone().normalize()
            },
            fg: {
              type: 'f',
              value: this.planetUtil.G
            },
            fg2: {
              type: 'f',
              value: this.planetUtil.G * this.planetUtil.G
            },
            fExposure: {
              type: 'f',
              value: this.planetUtil.exposure
            },
            fScaleDepth: {
              type: 'f',
              value: this.planetUtil.scaleDepth
            },
            fScaleOverScaleDepth: {
              type: 'f',
              value: this.planetUtil.scaleOverScaleDepth
            },
            fSamples: {
              type: 'f',
              value: this.planetUtil.nSamples
            },
            v3InvWavelength: {
              type: 'v3',
              value: this.planetUtil.invWavelength4
            },
            fKrESun: {
              type: 'f',
              value: this.planetUtil.KrESun
            },
            fKmESun: {
              type: 'f',
              value: this.planetUtil.KmESun
            },
            fOuterRadius: {
              type: 'f',
              value: this.planetUtil.outerRadius
            },
            fInnerRadius: {
              type: 'f',
              value: this.planetUtil.innerRadius
            },
            fOuterRadius2: {
              type: 'f',
              value: this.planetUtil.outerRadius * this.planetUtil.outerRadius
            },
            fKr4PI: {
              type: 'f',
              value: this.planetUtil.Kr4PI
            },
            fKm4PI: {
              type: 'f',
              value: this.planetUtil.Km4PI
            },
            fScale: {
              type: 'f',
              value: this.planetUtil.scale
            }
          };
        };

        Planet.prototype.createShaderSkyFromAtmosphere = function() {
          var uniformsBase;
          uniformsBase = THREE.UniformsUtils.clone(this.baseUniforms);
          return this.mSkyFromAtmosphere = new THREE.ShaderMaterial({
            uniforms: uniformsBase,
            vertexShader: SkyFromAtmosphereVert,
            fragmentShader: SkyFromAtmosphereFrag,
            side: THREE.BackSide,
            shading: THREE.SmoothShading,
            depthWrite: false,
            transparent: true
          });
        };

        Planet.prototype.createShaderSkyFromSpace = function() {
          var uniformsBase;
          uniformsBase = THREE.UniformsUtils.clone(this.baseUniforms);
          return this.mSkyFromSpace = new THREE.ShaderMaterial({
            uniforms: uniformsBase,
            vertexShader: SkyFromSpaceVert,
            fragmentShader: SkyFromSpaceFrag,
            side: THREE.BackSide,
            shading: THREE.SmoothShading,
            depthWrite: false,
            transparent: true
          });
        };

        Planet.prototype.createShaderGroundFromSpace = function() {
          var bumpTexture, nightTexture, planetTexture, uniformsBase, uniformsGround;
          planetTexture = THREE.ImageUtils.loadTexture("textures/earth_atmos_2048.jpg");
          nightTexture = THREE.ImageUtils.loadTexture("textures/earthnight.jpg");
          bumpTexture = THREE.ImageUtils.loadTexture("textures/earthbump.png");
          uniformsBase = THREE.UniformsUtils.clone(this.baseUniforms);
          uniformsGround = {
            tGround: {
              type: 't',
              value: planetTexture
            },
            tNight: {
              type: 't',
              value: nightTexture
            },
            tBump: {
              type: 't',
              value: bumpTexture
            }
          };
          $.extend(uniformsBase, uniformsGround);
          return this.mGroundFromSpace = new THREE.ShaderMaterial({
            uniforms: uniformsBase,
            vertexShader: GroundFromSpaceVert,
            fragmentShader: GroundFromSpaceFrag,
            shading: THREE.SmoothShading
          });
        };

        Planet.prototype.createShaderGroundFromAtmosphere = function() {
          var nightTexture, planetTexture, uniformsBase, uniformsGround;
          planetTexture = THREE.ImageUtils.loadTexture("textures/earth_atmos_2048.jpg");
          nightTexture = THREE.ImageUtils.loadTexture("textures/earthnight.jpg");
          uniformsBase = THREE.UniformsUtils.clone(this.baseUniforms);
          uniformsGround = {
            tGround: {
              type: 't',
              value: planetTexture
            },
            tNight: {
              type: 't',
              value: nightTexture
            }
          };
          $.extend(uniformsBase, uniformsGround);
          return this.mGroundFromAtmosphere = new THREE.ShaderMaterial({
            uniforms: uniformsBase,
            vertexShader: GroundFromAtmosphereVert,
            fragmentShader: GroundFromAtmosphereFrag,
            shading: THREE.SmoothShading
          });
        };

        return Planet;

      })(THREE.Object3D)
    });
  });

}).call(this);
