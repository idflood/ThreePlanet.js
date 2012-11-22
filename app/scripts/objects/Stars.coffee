define [
  'vendor/namespace',
  'Three'
],
() ->
  namespace "ThreePlanet.objects",
    Stars: class Stars extends THREE.Object3D
      constructor: () ->
        super

        starsGeometry = new THREE.Geometry()
        num = 7500
        radius = 200
        starsMaterials = []

        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x555555, size: 2, sizeAttenuation: false } ))
        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x555555, size: 1, sizeAttenuation: false } ))
        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x333333, size: 2, sizeAttenuation: false } ))
        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x3a3a3a, size: 1, sizeAttenuation: false } ))
        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x1a1a1a, size: 2, sizeAttenuation: false } ))
        starsMaterials.push(new THREE.ParticleBasicMaterial( { color: 0x1a1a1a, size: 1, sizeAttenuation: false } ))
        for i in [0..num-1]
          vertex = new THREE.Vector3()
          vertex.x = Math.random() * 2 - 1
          vertex.y = Math.random() * 2 - 1
          vertex.z = Math.random() * 2 - 1
          vertex.multiplyScalar( radius )
          starsGeometry.vertices.push( vertex )
        for i in [10..100-1]
          stars = new THREE.ParticleSystem( starsGeometry, starsMaterials[ i % 6 ] )
          stars.rotation.x = Math.random() * 6
          stars.rotation.y = Math.random() * 6
          stars.rotation.z = Math.random() * 6

          s = i * 10
          stars.scale.set( s, s, s )

          stars.matrixAutoUpdate = false
          stars.updateMatrix()

          @add( stars )
