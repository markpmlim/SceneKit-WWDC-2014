/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how geometries are made.
*/

import SceneKit

// slide #6
class AAPLSlideGeometry: APPLSlide {
    var _teapotNodeForPositionsAndNormals: SCNNode?
    var _teapotNodeForUVs: SCNNode?
    var _teapotNodeForMaterials: SCNNode?
    var _positionsVisualizationNode: SCNNode?
    var _normalsVisualizationNode: SCNNode?
    
    required init() {
        _positionsVisualizationNode = SCNNode()
        _normalsVisualizationNode = SCNNode()
        super.init()
    }

    override var numberOfSteps: UInt {
        return 6
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch stepIndex {
        case 0:
            // Show what needs to be shown, hide what needs to be hidden
            _positionsVisualizationNode?.opacity = 1.0
            _normalsVisualizationNode?.opacity = 1.0
            _teapotNodeForUVs?.opacity = 0.0
            _teapotNodeForMaterials?.opacity = 1.0

            _teapotNodeForPositionsAndNormals?.opacity = 0.0

            // Don't highlight bullets (this is useful when we go back from the next slide)
            self.textManager.highlightBullet(at: UInt.max)
        case 1:
            do {
                self.textManager.highlightBullet(at: 0)

                let explodeAnimation = CABasicAnimation(keyPath: "explodeValue")
                explodeAnimation.duration = 2.0
                explodeAnimation.repeatCount = .greatestFiniteMagnitude
                explodeAnimation.autoreverses = true
                explodeAnimation.toValue = 20.0
                explodeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                _teapotNodeForPositionsAndNormals?.geometry?.addAnimation(explodeAnimation,
                                                                          forKey: "explode")
            }
        case 2:
            do {
                self.textManager.highlightBullet(at: 1)
                
                // Remove the "explode" animation and freeze the "explodeValue" parameter to the current value
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    let explodeValue = _teapotNodeForPositionsAndNormals?.presentation.geometry?.value(forKey: "explodeValue")
                    // "explodeValue" is a (float) uniform in shader modifier explode.shader.
                    // Swift will convert the float to an instance of NSNumber automatically.
                    _teapotNodeForPositionsAndNormals?.geometry?.setValue(explodeValue,
                                                                          forKey: "explodeValue")
                    _teapotNodeForPositionsAndNormals?.geometry?.removeAnimation(forKey: "explode")
                }
                SCNTransaction.commit()
                
                // Animate to a "no explosion" state and show the positions on completion
                func showPositions() -> Void {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 1.0
                    do {
                        self._positionsVisualizationNode?.opacity = 1.0
                    }
                    SCNTransaction.commit()
                }

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                SCNTransaction.completionBlock = showPositions
                do {
                    _teapotNodeForPositionsAndNormals?.geometry?.setValue(0.0,
                                                                          forKey: "explodeValue")
                }
                SCNTransaction.commit()
            }
        case 3:
            do {
                self.textManager.highlightBullet(at: 2)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    _positionsVisualizationNode?.opacity = 0.0
                    _normalsVisualizationNode?.opacity = 1.0
                }
                SCNTransaction.commit()
            }
        case 4:
            do {
                self.textManager.highlightBullet(at: 3)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    _normalsVisualizationNode?.isHidden = true
                    _teapotNodeForUVs?.opacity = 1.0
                    _teapotNodeForPositionsAndNormals?.opacity = 0.0
                }
                SCNTransaction.commit()
            }
        case 5:
            do {
                self.textManager.highlightBullet(at: 4)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.0
                do {
                    _teapotNodeForUVs?.isHidden = true
                    _teapotNodeForMaterials?.opacity = 1.0
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Node Attributes")
        _ = self.textManager.set(subtitle: "SCNGeometry")

        _ = self.textManager.add(bullet: "Triangles", at: 0)
        _ = self.textManager.add(bullet: "Vertices", at: 0)
        _ = self.textManager.add(bullet: "Normals", at: 0)
        _ = self.textManager.add(bullet: "UVs", at: 0)
        _ = self.textManager.add(bullet: "Materials", at: 0)
        // We create a container for several versions of the teapot model
        // - one teapot to show positions and normals
        // - one teapot to show texture coordinates
        // - one teapot to show materials
        let allTeapotsNode = SCNNode()
        self.groundNode.addChildNode(allTeapotsNode)

        // why no file extension need to be specified?
        _teapotNodeForPositionsAndNormals = allTeapotsNode.asc_addChildNode(named: "TeapotLowRes",
                                                                            fromSceneNamed: "Scenes.scnassets/teapots/teapotLowRes",
                                                                            withScale: 17)
        _teapotNodeForUVs = allTeapotsNode.asc_addChildNode(named: "Teapot01",
                                                            fromSceneNamed: "Scenes.scnassets/teapots/teapotMaterial",
                                                            withScale: 17)
        _teapotNodeForMaterials = allTeapotsNode.asc_addChildNode(named: "teapotMaterials",
                                                                  fromSceneNamed: "Scenes.scnassets/teapots/teapotMaterial",
                                                                  withScale: 17)

        _teapotNodeForPositionsAndNormals?.position = SCNVector3Make(4, 0, 0)
        _teapotNodeForUVs?.position = SCNVector3Make(4, 0, 0)
        _teapotNodeForMaterials?.position = SCNVector3Make(4, 0, 0)

        _teapotNodeForMaterials?.childNodes(passingTest: {
            (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>)-> Bool in
            for material in (child.geometry?.materials)! {
                material.multiply.contents = "Scenes.scnassets/teapots/UVs.png"
                material.multiply.wrapS = .repeat
                material.multiply.wrapT = .repeat
                // material.reflective.contents = NSColor.white
                // material.reflective.intensity = 3.0
                // material.fresnelExponent = 3.0
            }
            return false
        })

        // Animate the teapots (rotate forever)
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.duration = 40.0
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        rotationAnimation.toValue = NSValue(scnVector4:SCNVector4Make(0, 1, 0,
                                                                      (CGFloat.pi * 2.0)))

        _teapotNodeForPositionsAndNormals?.addAnimation(rotationAnimation,
                                                        forKey: nil)
        _teapotNodeForUVs?.addAnimation(rotationAnimation,
                                        forKey: nil)
        _teapotNodeForMaterials?.addAnimation(rotationAnimation,
                                              forKey: nil)

        let explodeShaderPath = Bundle.main.path(forResource: "explode",
                                                 ofType: "shader")

        var explodeShaderSource: String?
        do {
            try explodeShaderSource = String(contentsOfFile: explodeShaderPath!)
        }
        catch _ {
            
        }
        // The class SCNGeometry implements the SCNShadable required property "shaderModifiers"
        // vertex processing stage
        _teapotNodeForPositionsAndNormals?.geometry?.shaderModifiers = [ .geometry : explodeShaderSource!]

        // Build nodes that will help visualize the vertices (position and normal)
        self.buildVisualizations(ofNode: _teapotNodeForPositionsAndNormals!,
                                 positionsNode: &_positionsVisualizationNode!,
                                 normalsNode: &_normalsVisualizationNode!)

        _normalsVisualizationNode?.castsShadow = false
        
        _teapotNodeForMaterials?.addChildNode(_positionsVisualizationNode!)
        _teapotNodeForMaterials?.addChildNode(_normalsVisualizationNode!)
    }

    func buildVisualizations(ofNode node: SCNNode,
                             positionsNode verticesNode: inout SCNNode,
                             normalsNode: inout SCNNode) {

        // A material that will prevent the nodes from being lit
        let noLightingMaterial = SCNMaterial()
        noLightingMaterial.lightingModel = .constant

        let normalMaterial = SCNMaterial()
        normalMaterial.lightingModel = .constant
        normalMaterial.diffuse.contents = NSColor.red

        // Create nodes to represent the vertex and normals
        let positionVisualizationNode = SCNNode()
        let normalsVisualizationNode = SCNNode()

        // Retrieve the positions and normals of the vertices from the model
        let positionSource = node.geometry?.getGeometrySources(for: .vertex)[0]
        let normalSource = node.geometry?.getGeometrySources(for: .normal)[0]


        // Get vertex and normal (data buffer) bytes
        let vertexBuffer = NSData(data: (positionSource?.data)!).bytes.bindMemory(to: Float.self,
                                                                                  capacity: (positionSource?.data.count)!/4)
        let nsdata = (normalSource?.data)! as NSData
        let normalBuffer = nsdata.bytes.assumingMemoryBound(to: Float.self)

        let stride = (positionSource?.dataStride)! / MemoryLayout<Float>.size
        let normalOffset = (normalSource?.dataOffset)! / MemoryLayout<Float>.size

        // Iterate and create geometries to represent the positions and normals
        for i in 0..<positionSource!.vectorCount {
            // One new node per normal/vertex
            let vertexNode = SCNNode()
            let normalNode = SCNNode()

            // Attach one sphere per vertex
            let sphere = SCNSphere(radius: 0.5)
            sphere.isGeodesic = true
            sphere.segmentCount = 0     // use a small segment count for better performances
            sphere.firstMaterial = noLightingMaterial
            vertexNode.geometry = sphere

            // And one pyramid per normal
            let pyramid = SCNPyramid(width: 0.1,
                                     height: 0.1,
                                     length: 8.0)
            pyramid.firstMaterial = normalMaterial
            normalNode.geometry = pyramid


            // Place the position node
            vertexNode.position = SCNVector3Make(CGFloat(vertexBuffer[i * stride + 0]),
                                                 CGFloat(vertexBuffer[i * stride + 1]),
                                                 CGFloat(vertexBuffer[i * stride + 2]))
            // Place the normal node
            normalNode.position = vertexNode.position

            // Orientate the normal
            let up = GLKVector3Make(0, 0, 1)
            let normalVec = GLKVector3Make(normalBuffer[i * stride + 0+normalOffset],
                                           normalBuffer[i * stride + 1+normalOffset],
                                           normalBuffer[i * stride + 2+normalOffset])

            let axis = GLKVector3Normalize(GLKVector3CrossProduct(up, normalVec))
            let dotProduct = GLKVector3DotProduct(up, normalVec)
            normalNode.rotation = SCNVector4Make(CGFloat(axis.x),
                                                 CGFloat(axis.y),
                                                 CGFloat(axis.z),
                                                 acos(CGFloat(dotProduct)))

            // Add the nodes to their parent
            positionVisualizationNode.addChildNode(vertexNode)
            normalsVisualizationNode.addChildNode(normalNode)
        }

        // We must flush the transaction in order to make sure that the parametric geometries (sphere and pyramid)
        // are up-to-date before flattening the nodes
        SCNTransaction.flush()
        
        // Flatten the visualization nodes so that they can be rendered with 1 draw call
        verticesNode = positionVisualizationNode.flattenedClone()
        normalsNode = normalsVisualizationNode.flattenedClone()
    }
}
