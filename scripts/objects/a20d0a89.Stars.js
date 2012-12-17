(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['vendor/namespace', 'Three'], function() {
    var Stars;
    return namespace("ThreePlanet.objects", {
      Stars: Stars = (function(_super) {

        __extends(Stars, _super);

        function Stars() {
          var i, num, radius, s, stars, starsGeometry, starsMaterials, vertex, _i, _j, _ref, _ref1;
          Stars.__super__.constructor.apply(this, arguments);
          starsGeometry = new THREE.Geometry();
          num = 7500;
          radius = 200;
          starsMaterials = [];
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x555555,
            size: 2,
            sizeAttenuation: false
          }));
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x555555,
            size: 1,
            sizeAttenuation: false
          }));
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x333333,
            size: 2,
            sizeAttenuation: false
          }));
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x3a3a3a,
            size: 1,
            sizeAttenuation: false
          }));
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x1a1a1a,
            size: 2,
            sizeAttenuation: false
          }));
          starsMaterials.push(new THREE.ParticleBasicMaterial({
            color: 0x1a1a1a,
            size: 1,
            sizeAttenuation: false
          }));
          for (i = _i = 0, _ref = num - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            vertex = new THREE.Vector3();
            vertex.x = Math.random() * 2 - 1;
            vertex.y = Math.random() * 2 - 1;
            vertex.z = Math.random() * 2 - 1;
            vertex.multiplyScalar(radius);
            starsGeometry.vertices.push(vertex);
          }
          for (i = _j = 10, _ref1 = 100 - 1; 10 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 10 <= _ref1 ? ++_j : --_j) {
            stars = new THREE.ParticleSystem(starsGeometry, starsMaterials[i % 6]);
            stars.rotation.x = Math.random() * 6;
            stars.rotation.y = Math.random() * 6;
            stars.rotation.z = Math.random() * 6;
            s = i * 10;
            stars.scale.set(s, s, s);
            stars.matrixAutoUpdate = false;
            stars.updateMatrix();
            this.add(stars);
          }
        }

        return Stars;

      })(THREE.Object3D)
    });
  });

}).call(this);
