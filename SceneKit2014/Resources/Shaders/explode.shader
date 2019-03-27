uniform float explodeValue = 0.0;       // wrapped as an NSNumber object

#pragma body

 _geometry.position.xyz += _geometry.normal * explodeValue;
