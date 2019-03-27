/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Shows how Scene Kit allows one to use custom GLSL programs.

*/

import SceneKit

// slide #42
struct AAPLMorphVertex {
    var morphPositionSrc = GLKVector3()
    var morphPositionDst = GLKVector3()
    var texCoord = GLKVector2()
}

class AAPLSlideCustomProgram: APPLSlide, SCNProgramDelegate {
    var torusNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 3
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Custom Program")
        _ = self.textManager.set(subtitle: "SCNProgram")
        _ = self.textManager.add(bullet: "Custom GLSL code per material",
                                 at: 0)
        _ = self.textManager.add(bullet: "Replaces SceneKit’s rendering",
                                 at: 0)
        _ = self.textManager.add(bullet: "Geometry attributes are provided",
                                 at: 0)
        _ = self.textManager.add(bullet: "Transform uniforms are also provided",
                                 at: 0)

        // Add a torus and animate it
        let intermediateNode = SCNNode()
        intermediateNode.position = SCNVector3Make(8, 8, 4)
        intermediateNode.rotation = SCNVector4Make(1, 0, 0,         // axis of rotation
                                                   -CGFloat.pi/2)   // angle of rotation

        self.groundNode.addChildNode(intermediateNode)
        
        torusNode = intermediateNode.asc_addChildNode(named: "torus",
                                                      fromSceneNamed: "Scenes.scnassets/torus/torus",
                                                      withScale: 10)
        torusNode?.name = "object";                                 // give it a name

        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.duration = 10.0
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4Make(0, 0, 1,
                                                                       (CGFloat.pi*2)))
        torusNode?.addAnimation(rotationAnimation,
                                forKey:nil)
    }


    // this method will create a new instance of SCNGeometry from the one passed in.
    func spriteGeometry(radius: CGFloat,
                        sourceGeometry geometry: SCNGeometry) -> SCNGeometry {

        // Expect only 1 such array
        let vertexSource = geometry.getGeometrySources(for: .vertex)[0]

        let vectorCount = vertexSource.vectorCount
        let vertexCount = vectorCount * 3
        // Beginning of the vertex's position attribute.
        let srcVertexData = vertexSource.data as NSData // + vertexSource.dataOffset
        // # of bytes to next vector in the data (buffer)
        let srcStride = vertexSource.dataStride
        let bytesPerVector = vertexSource.componentsPerVector * vertexSource.bytesPerComponent
        var dstVertices = [AAPLMorphVertex](repeating: AAPLMorphVertex(), count: vertexCount)

        for i in 0..<vectorCount {
            var positionData = [Float](repeating:0.0, count: vertexSource.componentsPerVector)
            let byteRange = NSMakeRange(i*srcStride+vertexSource.dataOffset, bytesPerVector)
            srcVertexData.getBytes(&positionData, range: byteRange)
            var position = GLKVector3Make(positionData[0], positionData[1], positionData[2])

            // source position
            dstVertices[i*3 + 0].morphPositionSrc = position
            dstVertices[i*3 + 1].morphPositionSrc = position
            dstVertices[i*3 + 2].morphPositionSrc = position
            // compute the destination position, a random point on a sphere of specified radius
            position = GLKVector3Make((2.0 * Float(arc4random()) / Float(RAND_MAX) - 1.0),
                                      (2.0 * Float(arc4random()) / Float(RAND_MAX) - 1.0),
                                      (2.0 * Float(arc4random()) / Float(RAND_MAX) - 1.0))

            position = GLKVector3MultiplyScalar(GLKVector3Normalize(position), Float(radius))
            dstVertices[i*3 + 0].morphPositionDst = position
            dstVertices[i*3 + 1].morphPositionDst = position
            dstVertices[i*3 + 2].morphPositionDst = position

            // texture coordinates
            dstVertices[i*3 + 0].texCoord = GLKVector2Make(-1.0, -1.0)
            dstVertices[i*3 + 1].texCoord = GLKVector2Make(3.0, -1.0)
            dstVertices[i*3 + 2].texCoord = GLKVector2Make(-1.0,  3.0)
        }

        // Create three geometry sources : position, normal and texture coordinates
        // The method bytesNoCopy:length:freeWhenDone will crash
        let interleavedVertexData = Data(bytes: dstVertices,
                                         count: vertexCount * MemoryLayout<AAPLMorphVertex>.size)

        let positionSource = SCNGeometrySource(data: interleavedVertexData,
                                               semantic: .vertex,
                                               vectorCount: vectorCount,
                                               usesFloatComponents: true,
                                               componentsPerVector: 3,
                                               bytesPerComponent: MemoryLayout<Float>.size,
                                               dataOffset: 0,
                                               dataStride: MemoryLayout<AAPLMorphVertex>.size)

        let normalSource = SCNGeometrySource(data: interleavedVertexData,
                                             semantic: .normal,
                                             vectorCount: vectorCount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: MemoryLayout<GLKVector3>.size,
                                             dataStride: MemoryLayout<AAPLMorphVertex>.size)

        let texCoordSource = SCNGeometrySource(data: interleavedVertexData,
                                               semantic: .texcoord,
                                               vectorCount: vectorCount,
                                               usesFloatComponents: true,
                                               componentsPerVector: 2,
                                               bytesPerComponent: MemoryLayout<Float>.size,
                                               dataOffset: MemoryLayout<GLKVector3>.size * 2,
                                               dataStride: MemoryLayout<AAPLMorphVertex>.size)

        // Create the indices (each vertex is used only once per triangle)
        var indices = [GLint](repeating: 0, count: vertexCount)
        for i in 0..<vertexCount {
            indices[i] = GLint(i)
        }

        let indicesData = Data(bytes: indices,
                               count: vertexCount * MemoryLayout<GLint>.size)


        // Create a geometry element from the indices
        let elements = SCNGeometryElement(data: indicesData,
                                          primitiveType: SCNGeometryPrimitiveType.triangles,
                                          primitiveCount: vertexCount / 3,
                                          bytesPerIndex: MemoryLayout<GLint>.size)

        // Create the geometry from the three geometry sources and the geometry element
        let newGeometry = SCNGeometry(sources: [positionSource, normalSource, texCoordSource],
                                      elements: [elements])

        // Use the same materials
        newGeometry.materials = geometry.materials

        return newGeometry
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch(stepIndex) {
        case 1:
            do {
                // Create the supporting geometry and replace the existing one
                torusNode = self.groundNode.childNode(withName: "object",
                                                      recursively: true)
                // Convert into 3D sprites
                torusNode?.geometry = self.spriteGeometry(radius: 8.0,
                                                          sourceGeometry: torusNode!.geometry!)

                // Create a custom program using a vertex and a fragment shader
                let vertexShaderURL = Bundle.main.url(forResource: "CustomProgram",
                                                      withExtension: "vsh")
                let fragmentShaderURL = Bundle.main.url(forResource: "CustomProgram",
                                                        withExtension: "fsh")


                let program = SCNProgram()
                program.isOpaque = false
                var vertexShader: String?
                do {
                    try vertexShader = String(contentsOf: vertexShaderURL!,
                                              encoding: String.Encoding.ascii)
                }
                catch _ {

                }

            var fragmentShader: String?
                do {
                    try fragmentShader = String(contentsOf: fragmentShaderURL!,
                                                encoding: String.Encoding.ascii)
                } catch _ {

                }

                program.vertexShader = vertexShader
                program.fragmentShader = fragmentShader
                program.delegate = self

                // Bind geometry source semantics to the vertex shader attributes
                program.setSemantic(SCNGeometrySource.Semantic.vertex.rawValue,
                                    forSymbol: "a_srcPos",
                                    options: nil)
                program.setSemantic(SCNGeometrySource.Semantic.normal.rawValue,
                                    forSymbol: "a_dstPos",
                                    options: nil)
                program.setSemantic(SCNGeometrySource.Semantic.texcoord.rawValue,
                                    forSymbol: "a_texcoord",
                                    options: nil)


                // Bind the uniforms that can benefit from "automatic" values, computed and assigned by SceneKit at each frame.
                program.setSemantic(SCNProjectionTransform,
                                    forSymbol: "u_proj",
                                    options: nil)
                program.setSemantic(SCNModelViewTransform,
                                    forSymbol: "u_mv",
                                    options: nil)

                let startTime = CFAbsoluteTimeGetCurrent()

                // bind to geometry will crash
                torusNode?.geometry?.firstMaterial!.handleBinding(ofSymbol: "time",
                                                                  handler: {

                    (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

                    // animate the "time" uniform to make the particles spin
                    glUniform1f(Int32(location), GLfloat(CFAbsoluteTimeGetCurrent() - startTime))
                })

                // Other uniforms will be set using binding blocks - these 2 are called before rendering
                // Qn: are the codes executed for every frame?
                var morphFactor: GLfloat = 0.0
                morphFactor = -GLfloat.pi/2

                // bind to geometry will crash
                torusNode?.geometry?.firstMaterial!.handleBinding(ofSymbol: "factor",
                                                                  handler: {

                    (programId: UInt32, location: UInt32, node: SCNNode?, renderer: SCNRenderer) -> Void in

                    // animate the "factor" uniform to morph from the original object to the sphere
                    morphFactor += 0.01
                    glUniform1f(Int32(location), GLfloat(sin(morphFactor) * 0.5 + 0.5))
                })


                // Use our custom program and make the material not to interact at all with
                // the depth buffer (to provide an additive effect)
                torusNode?.geometry?.firstMaterial!.program = program
                // The following statement does not work correctly; probably due to the fact
                // handleBindingOfSymbol:usingBlock: is on firstMaterial
                //torusNode?.geometry?.program = program
                torusNode?.geometry?.firstMaterial!.writesToDepthBuffer = false
                torusNode?.geometry?.firstMaterial!.readsFromDepthBuffer = false
                torusNode?.renderingOrder = 100; // as the geometry doesn't interact with the depth buffer, the node needs to be rendered last
            }
        case 2:
            do {
                // Display the related sample code
                self.textManager.fadeOutText(ofTextType: .bullet)
                self.textManager.addEmptyLine()
                // not displayed! - solved
                _ = self.textManager.add(code:
                    "[aMaterial #handleBindingOfSymbol:#@\"myUniform\" \n" +
                        "                      #usingBlock:# \n" +
                        "       ^(unsigned int programID, \n" +
                        "         unsigned int location, \n" +
                        "         SCNNode *node, \n" +
                        "         SCNRenderer *renderer) { \n" +
                        "    glUniform1f(location, aValue); \n" +
                    "}];")

                self.textManager.flipInText(ofTextType: .code)
            }
        default:
            break
        }
    }

    func program(_ program: SCNProgram, handleError error: Error) {
        NSLog("%@", error.localizedDescription);
    }

}
