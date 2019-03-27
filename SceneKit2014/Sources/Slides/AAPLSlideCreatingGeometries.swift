/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Presents the different types of geometry that one can create programmatically.

*/

import SceneKit

// Data structure representing a vertex that will be used to create custom geometries
struct AAPLVertex {
    var position: (Float, Float, Float)
    var normal: (Float, Float, Float)
    var uv: (Float, Float)              // texture coordinates
}

// slide #14
class AAPLSlideCreatingGeometries: APPLSlide {
    var carouselNode: SCNNode?
    var textNode: SCNNode?
    var starOutline: SCNNode?
    var starNode: SCNNode?
    var mobiusHandle: SCNNode?
    var subdivisionGroup: SCNNode?
    var currentStep: UInt?

    required init() {
        starNode = SCNNode()
        starOutline = SCNNode()
        super.init()
    }

    override var numberOfSteps: UInt {
        return 6
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title
        _ = self.textManager.set(title: "Creating Geometry")

        // Set the slide's subtitle and display the primitves
        _ = self.textManager.set(subtitle: "Built-in parametric primitives")
    }

    override func present(stepIndex: UInt,
                          with presentationViewController : AAPLPresentationViewController) {
        currentStep = stepIndex
        switch (stepIndex) {
        case 0:
            break;
        case 1:
            // Hide the carousel and illustrate SCNText
            self.textManager.flipOutText(ofTextType: .subtitle)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            SCNTransaction.completionBlock = {
                self.carouselNode?.removeFromParentNode()
            }
            self.presentTextNode()
            
            textNode?.opacity = 1.0
            
            carouselNode?.position = SCNVector3Make(0, (carouselNode?.position.y)!, -50)
            carouselNode?.enumerateChildNodes({
                (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                child.geometry?.firstMaterial?.emission.contents = NSColor.black
            })
            carouselNode?.opacity = 0.0

            SCNTransaction.commit()
            
            _ = self.textManager.set(subtitle: "Built-in 3D text")
            _ = self.textManager.add(bullet: "SCNText",
                                 at: 0)
            self.textManager.flipInText(ofTextType: .subtitle)
            self.textManager.flipInText(ofTextType: .bullet)

        case 2:
            //Show bezier path
            let star = self.starPath(innerRadius: 3,
                                     outerRadius: 6)

            let shape = SCNShape(path: star,
                                 extrusionDepth: 1)
            shape.chamferRadius = 0.2
            shape.chamferProfile = self.chamferProfileForOutline()
            shape.chamferMode = .front

            // that way only the outline of the model will be visible
            let outlineMaterial = SCNMaterial()
            outlineMaterial.ambient.contents = NSColor.black
            outlineMaterial.diffuse.contents = NSColor.black
            outlineMaterial.specular.contents = NSColor.black
            outlineMaterial.emission.contents = NSColor.white
            outlineMaterial.isDoubleSided = true

            let tranparentMaterial = SCNMaterial()
            tranparentMaterial.transparency = 0.0
 
            shape.materials = [tranparentMaterial, tranparentMaterial, tranparentMaterial, outlineMaterial, outlineMaterial]
            
            starOutline = SCNNode()
            starOutline?.geometry = shape
            starOutline?.position = SCNVector3Make(0, 5, 30)
            starOutline?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                              y: CGFloat.pi*2,
                                                                              z: 0,
                                                                              duration: 10.0)))

            self.groundNode.addChildNode(starOutline!)
 
            // Hide the 3D text and introduce SCNShape
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            SCNTransaction.completionBlock = {
                self.textNode?.removeFromParentNode()
            }

            self.textManager.flipOutText(ofTextType: .subtitle)
            self.textManager.flipOutText(ofTextType: .bullet)

            _ = self.textManager.set(subtitle:"3D Shapes")
            
            _ = self.textManager.add(bullet: "SCNShape",
                                     at: 0)

            self.textManager.flipInText(ofTextType: .subtitle)
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)

            starOutline?.position = SCNVector3Make(0, 5, 0)
            textNode?.position = SCNVector3Make((textNode?.position.x)!, (textNode?.position.y)!, -30)


            SCNTransaction.commit()
        case 3:
            let star = self.starPath(innerRadius: 3,
                                     outerRadius: 6)

            let shape = SCNShape(path: star,
                                 extrusionDepth: 0)
            shape.chamferRadius = 0.1;

            starNode = SCNNode()
            starNode?.geometry = shape
            let material = SCNMaterial()
            material.reflective.contents = "color_envmap.png"
            material.diffuse.contents = NSColor.black
            starNode?.geometry?.materials = [material]
            starNode?.position = SCNVector3Make(0, 5, 0)
            starNode?.pivot = SCNMatrix4MakeTranslation(0, 0, -0.5)
            starOutline?.parent?.addChildNode(starNode!)

            starNode?.eulerAngles = (starOutline?.eulerAngles)!
            starNode?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                           y: CGFloat.pi * 2,
                                                                           z: 0,
                                                                           duration: 10.0)))

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            SCNTransaction.completionBlock = {
                self.starOutline?.removeFromParentNode()
            }

            shape.extrusionDepth = 1
            starOutline?.opacity = 0.0

            SCNTransaction.commit()
        case 4:
            //CUSTOM GEOMETRY
            self.textManager.flipOutText(ofTextType: .subtitle)
            self.textManager.flipOutText(ofTextType: .bullet)

            // Example of a custom geometry (Möbius strip)
            _ = self.textManager.set(subtitle: "Custom geometry")

            _ = self.textManager.add(bullet: "Custom vertices, normals, and texture coordinates",
                                     at: 0)
            _ = self.textManager.add(bullet: "SCNGeometry",
                                     at: 0)

            self.textManager.flipInText(ofTextType: .subtitle)
            self.textManager.flipInText(ofTextType: .bullet)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            do {
                SCNTransaction.completionBlock = {
                    self.starNode?.removeFromParentNode()
                }
                // move the camera back to its previous position
                presentationViewController.cameraNode?.position = SCNVector3Make(0, 0, 0)
                presentationViewController.cameraPitch?.rotation = SCNVector4Make(1, 0, 0,
                                                                                 self.pitch * CGFloat.pi / 180.0)

                starNode?.position = SCNVector3Make((starNode?.position.x)!,
                                                   (starNode?.position.y)!,
                                                   (starNode?.position.z)! - 30)
                starOutline?.position = SCNVector3Make((starOutline?.position.x)!,
                                                      (starOutline?.position.y)!,
                                                      (starOutline?.position.z)! - 30)

                let mobiusNode = SCNNode()
                mobiusNode.geometry = self.mobiusStrip(with: 150)
                mobiusNode.rotation = SCNVector4Make(1, 0, 0, -CGFloat.pi/4)
                mobiusNode.scale = SCNVector3Make(4.5, 2.8, 2.8);
                
                let rotationNode = SCNNode()
                rotationNode.addChildNode(mobiusNode)
                
                rotationNode.position = SCNVector3Make(0, 4, 30)
                self.groundNode.addChildNode(rotationNode)

                rotationNode.position = SCNVector3Make(0, 4, 3.5)
                
                rotationNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                                  y: CGFloat.pi*2,
                                                                                  z: 0,
                                                                                  duration: 10.0)))

                mobiusHandle = rotationNode
            }
            SCNTransaction.commit()
        case 5:
            //OpenSubdiv
            self.textManager.flipOutText(ofTextType: .subtitle)
            self.textManager.flipOutText(ofTextType: .bullet)

            _ = self.textManager.set(subtitle: "Subdivisions")
            _ = self.textManager.add(bullet: "OpenSubdiv",
                                     at: 0)
            _ = self.textManager.add(code: "aGeometry.#subdivisionLevel# = anInteger;")
            
            self.textManager.flipInText(ofTextType: .subtitle)
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)

            //add boxes
            let boxesNode = SCNNode()

            let level0 = boxesNode.asc_addChildNode(named: "rccarBody_LP",
                                                    fromSceneNamed: "Scenes.scnassets/car/car_lowpoly.dae",
                                                    withScale: 10)
            level0.position = SCNVector3Make(-6, level0.position.y, 0)


            var label = SCNNode.asc_boxNode(title: "0",
                                            frame: NSMakeRect(0, 0, 40, 40),
                                            color: NSColor.orange,
                                            cornerRadius: 20.0,
                                            centered: true)
            label.position = SCNVector3Make(0, -35, 10)
            label.scale = SCNVector3Make(0.3, 0.3, 0.001)
            level0 .addChildNode(label)


            boxesNode.position = SCNVector3Make(0, 0, 30)

            let level1 = level0.clone()
            level1.enumerateChildNodes( {
                (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if (child.name == "engine_LP") {
                    return
                }
                child.geometry = child.geometry?.copy() as! SCNGeometry?
                child.geometry?.subdivisionLevel = 3
            })

            level1.position = SCNVector3Make(6, level1.position.y, 0)
            boxesNode.addChildNode(level1)

            label = SCNNode.asc_boxNode(title: "2",
                                        frame: NSMakeRect(0, 0, 40, 40),
                                        color: NSColor.orange,
                                        cornerRadius: 20.0,
                                        centered: true)
            label.position = SCNVector3Make(0, -35, 10)
            label.scale = SCNVector3Make(0.3, 0.3, 0.001)
            level1.addChildNode(label)

            level0.runAction(SCNAction.repeatForever(SCNAction.rotate(by: 2.0 * CGFloat.pi,
                                                                      around: SCNVector3Make(0, 1, 0),
                                                                      duration: 25.0)))
            level1.runAction(SCNAction.repeatForever(SCNAction.rotate(by: 2.0 * CGFloat.pi,
                                                                      around: SCNVector3Make(0, 1, 0),
                                                                      duration: 25.0)))


            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            do {
                SCNTransaction.completionBlock = {
                    self.mobiusHandle?.removeFromParentNode()
                }

                // move moebius out
                mobiusHandle?.position = SCNVector3Make((mobiusHandle?.position.x)!,
                                                        (mobiusHandle?.position.y)!,
                                                        (mobiusHandle?.position.z)! - 30)
 
                self.groundNode.addChildNode(boxesNode)

                //move boxes in
                boxesNode.position = SCNVector3Make(0, 0, 3.5)
            }

            SCNTransaction.commit()

            subdivisionGroup = boxesNode

        default:
            break
        }
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        if currentStep == 0 {
            self.presentPrimitives()
        }
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        // Make sure the camera is back to its default location before leaving the slide
        presentationViewController.cameraNode?.position = SCNVector3Make(0, 0, 0)

        // Move bananas out
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        subdivisionGroup?.position = SCNVector3Make((subdivisionGroup?.position.x)!,
                                                    (subdivisionGroup?.position.y)!,
                                                    ((subdivisionGroup?.position.z)!-30))
        SCNTransaction.commit()
    }

    // Takes a string an creates a node hierarchy where each letter is an independent geometry that is animated
    func splittedStylizedText(with string: String) -> SCNNode {

        let textNode = SCNNode()
        let frontMaterial = self.textFrontMaterial()
        let border = self.textSideAndChamferMaterial()

        // Current x position of the next letter to add
        var positionX: CGFloat = 0;

        // For each letter
        for char in string.characters {

            let letterNode = SCNNode()
            let letterString = String(char)
            let text = SCNText(string: self.attributedString(with: letterString),
                               extrusionDepth:50.0)

            text.chamferRadius = 3.0
            text.chamferProfile = self.textChamferProfile()

            // use a different material for the "heart" character
            var finalFrontMaterial = frontMaterial
            if (char == "❤︎") {
                finalFrontMaterial = finalFrontMaterial.copy() as! SCNMaterial
                finalFrontMaterial.diffuse.contents = NSColor.red
                finalFrontMaterial.reflective.contents = NSColor.black
                letterNode.scale = SCNVector3Make(1.1, 1.1, 1.0);
            }

            text.materials = [finalFrontMaterial, finalFrontMaterial, border, border, border]

            letterNode.geometry = text;
            textNode.addChildNode(letterNode)

            // measure the letter we just added to update the position
            let (min, max) = letterNode.boundingBox
            if  SCNVector3EqualToVector3(min, SCNVector3Zero) &&
                SCNVector3EqualToVector3(max, SCNVector3Zero) {
                // if we have no bounding box, it is probably because of the "space" character. 
                // In that case, move to the right a little bit.
                positionX += 50.0
            }
            else {
                letterNode.position = SCNVector3Make(positionX - min.x + ( max.x + min.x) * 0.5, -min.y, 0)
                positionX += max.x
            }
            // Place the pivot at the center of the letter so that the rotation animation looks good
            letterNode.pivot = SCNMatrix4MakeTranslation((max.x + min.x) * 0.5, 0, 0)

            // Animate the letter
            let animation = CAKeyframeAnimation(keyPath: "rotation")
            animation.duration = 4.0;
            animation.keyTimes = [0.0, 0.3, 1.0]
            animation.values = [
                NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)),
                NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi * 2)),
                NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi * 2))
            ]
            let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.timingFunctions = [timingFunction, timingFunction, timingFunction]
            animation.repeatCount = Float.greatestFiniteMagnitude

            var value: UInt32
            if char != "❤︎" {
                let charStr = String(char)
                let scalars = charStr.unicodeScalars
                value = scalars[scalars.startIndex].value
            }
            else {
                value = 256     // value of the heart symbol is too big for animation
            }

            animation.beginTime = CACurrentMediaTime() + 1.0 + Double(value) * 0.02 // desynchronize animations
            letterNode.addAnimation(animation, forKey:nil)
        }

        return textNode;
    }

    func presentTextNode() {
        textNode = self.splittedStylizedText(with: "I❤︎SceneKit")
        textNode?.scale = SCNVector3Make(0.017, 0.0187, 0.017)
        textNode?.opacity = 0.0

        textNode?.position = SCNVector3Make(-14, 0, 30)

        self.groundNode.addChildNode(textNode!)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        textNode?.position = SCNVector3Make(-14, 0, 0)
        SCNTransaction.commit()
    }

    // Create a carousel of 3D primitives
    func presentPrimitives() {

        // Create the carousel node. It will host all the primitives as child nodes.
        carouselNode = SCNNode()
        carouselNode?.position = SCNVector3Make(0, 0.1, -5)
        carouselNode?.scale = SCNVector3Make(0, 0, 0)   // start infinitely small
        self.groundNode.addChildNode(carouselNode!)

        // Animate the scale to achieve a "grow" effect
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            carouselNode?.scale = SCNVector3Make(1, 1, 1)
        }
        SCNTransaction.commit()

        // Rotate the carousel forever
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.duration = 40.0
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude


        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       CGFloat.pi * 2))
        carouselNode?.addAnimation(rotationAnimation,
                                   forKey:nil)

        // A material shared by all the primitives
        let sharedMaterial = SCNMaterial()
        sharedMaterial.reflective.contents = NSImage(named: "envmap")
        sharedMaterial.reflective.intensity = 0.2
        sharedMaterial.isDoubleSided = true

        var primitiveIndex: Int = 0
        func addPrimitive(_ geometry: SCNGeometry, _ yPos: CGFloat) -> Void {
            let xPos: CGFloat = 13.0 * sin(CGFloat.pi * 2 * CGFloat(primitiveIndex) / 9.0)
            let zPos: CGFloat = 13.0 * cos(CGFloat.pi * 2 * CGFloat(primitiveIndex) / 9.0)

            let node = SCNNode()
            node.position = SCNVector3Make(xPos, yPos, zPos)
            node.geometry = geometry
            node.geometry?.firstMaterial = sharedMaterial
            carouselNode?.addChildNode(node)

            primitiveIndex += 1
            rotationAnimation.timeOffset = -Double(primitiveIndex)
            node.addAnimation(rotationAnimation, forKey: nil)
        }

        // SCNBox
        let box = SCNBox(width: 5.0, height: 5.0, length: 5.0, chamferRadius: 5.0 * 0.05)
        box.widthSegmentCount = 4
        box.heightSegmentCount = 4
        box.lengthSegmentCount = 4
        box.chamferSegmentCount = 4
        addPrimitive(box, 5.0 / 2)

        // SCNPyramid
        let pyramid = SCNPyramid(width: 5.0 * 0.8, height: 5.0, length: 5.0 * 0.8)
        pyramid.widthSegmentCount = 4
        pyramid.heightSegmentCount = 10
        pyramid.lengthSegmentCount = 4
        addPrimitive(pyramid, 0)

        // SCNCone
        let cone = SCNCone(topRadius: 0, bottomRadius: 5.0 / 2, height:5.0)
        cone.radialSegmentCount = 20
        cone.heightSegmentCount = 4
        addPrimitive(cone, 5.0 / 2)

        // SCNTube
        let tube = SCNTube(innerRadius: 5.0 * 0.25, outerRadius: 5.0 * 0.5, height: 5.0)
        tube.heightSegmentCount = 5
        tube.radialSegmentCount = 40
        addPrimitive(tube, 5.0 / 2)

        // SCNCapsule
        let capsule = SCNCapsule(capRadius: 5.0 * 0.4, height: 5.0 * 1.4)
        capsule.heightSegmentCount = 5
        capsule.radialSegmentCount = 20
        addPrimitive(capsule, 5.0 * 0.7)

        // SCNCylinder
        let cylinder = SCNCylinder(radius: 5.0 * 0.5, height: 5.0)
        cylinder.heightSegmentCount = 5
        cylinder.radialSegmentCount = 40
        addPrimitive(cylinder, 5.0 / 2)

        // SCNSphere
        let sphere = SCNSphere(radius: 5.0 * 0.5)
        sphere.segmentCount = 20
        addPrimitive(sphere, 5.0 / 2)

        // SCNTorus
        let torus = SCNTorus(ringRadius: 5.0 * 0.5, pipeRadius: 5.0 * 0.25)
        torus.ringSegmentCount = 40
        torus.pipeSegmentCount = 20
        addPrimitive(torus, 5.0 / 4)

        // SCNPlane
        let plane = SCNPlane(width: 5.0, height: 5.0)
        plane.widthSegmentCount = 5
        plane.heightSegmentCount = 5
        plane.cornerRadius = 5.0 * 0.1
        addPrimitive(plane, 5.0 / 2)
    }

    //Custom geometry: something's wrong
    
    func mobiusStrip(with subdivisionCount: Int) -> SCNGeometry {
        let hSub = subdivisionCount
        let vSub = subdivisionCount / 2
        let vcount = (hSub + 1) * (vSub + 1)
        let icount = hSub * vSub * 6

        var vertices = [AAPLVertex](repeating: AAPLVertex(position: (0, 0, 0),
                                                          normal: (0, 0, 0),
                                                          uv: (0, 0)),
                                    count: vcount)
        var indices = [UInt32](repeating: 0, count: icount)

        // Vertices
        let sStep = 2.0 * Float.pi / Float(hSub)
        let tStep = 2.0 / Float(vSub)
        var s: Float = 0.0
        var cosu: Float, cosu2: Float, sinu: Float, sinu2: Float
        var k = 0
        for _ in 0...hSub {
            var t: Float = -1.0
            for _ in 0...vSub {
                sinu = sin(s)
                cosu = cos(s)
                sinu2 = sin(s/2)
                cosu2 = cos(s/2)
                let p0 = cosu * (1 + 0.5 * t * cosu2)
                let p1 = sinu * (1 + 0.5 * t * cosu2)
                let p2 = 0.5 * t * sinu2

                var n0 = -0.125 * t * sinu  + 0.5  * cosu  * sinu2 + 0.25 * t * cosu2 * sinu2 * cosu
                var n1 =  0.125 * t * cosu  + 0.5  * sinu2 * sinu  + 0.25 * t * cosu2 * sinu2 * sinu
                var n2 = -0.5       * cosu2 - 0.25 * cosu2 * cosu2 * t

                // normalize
                let invLen: Float = 1.0 / sqrtf(n0 * n0 + n1 * n1 + n2 * n2)
                n0 *= invLen
                n1 *= invLen
                n2 *= invLen


                let uv0 = 3.125 * s / Float.pi
                let uv1 = t * 0.5 + 0.5
                
                vertices[k] = AAPLVertex(position: (p0, p1, p2),
                                         normal: (n0, n1, n2),
                                         uv: (uv0, uv1) )
                t += tStep
                k += 1
            }
            s += sStep
        }

        // Indices
        var stripStart: UInt32 = 0
        k = 0
        for _ in 0..<hSub {
            for j in 0..<vSub {
                let v1  = stripStart + UInt32(j)
                let v2  = stripStart + UInt32(j) + 1
                let v3  = stripStart + UInt32(vSub+1) + UInt32(j)
                let v4  = stripStart + UInt32(vSub+1) + UInt32(j) + 1
                indices[k] = v1; k += 1
                indices[k] = v3; k += 1
                indices[k] = v2; k += 1
                indices[k] = v2; k += 1
                indices[k] = v3; k += 1
                indices[k] = v4; k += 1
            }
            stripStart += UInt32(vSub + 1)
        }

        let data = Data(bytes: vertices,
                        count: vcount * MemoryLayout<AAPLVertex>.size)

        // Vertex source
        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: vcount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<AAPLVertex>.size)

        // Normal source
        let normalSource = SCNGeometrySource(data: data,
                                             semantic: .normal,
                                             vectorCount:vcount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 3*MemoryLayout<Float>.size,
                                             dataStride: MemoryLayout<AAPLVertex>.size)
        // Texture coordinates source
        let texcoordSource = SCNGeometrySource(data: data,
                                               semantic: .texcoord,
                                               vectorCount:vcount,
                                               usesFloatComponents: true,
                                               componentsPerVector: 2,
                                               bytesPerComponent: MemoryLayout<Float>.size,
                                               dataOffset:  6*MemoryLayout<Float>.size,
                                               dataStride: MemoryLayout<AAPLVertex>.size)
        // Geometry element
        let indicesData = Data(bytes: indices,
                               count: icount * MemoryLayout<UInt32>.size)
        let element = SCNGeometryElement (data: indicesData as Data,
                                          primitiveType: .triangles,
                                          primitiveCount: icount/3,
                                          bytesPerIndex: MemoryLayout<UInt32>.size)

        // Create the geometry
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, texcoordSource],
                                   elements:[element])
        // Add textures
        geometry.firstMaterial = SCNMaterial()
        geometry.firstMaterial?.diffuse.contents = NSImage(named: "moebius")
        geometry.firstMaterial?.diffuse.wrapS = .repeat
        geometry.firstMaterial?.diffuse.wrapT = .repeat
        geometry.firstMaterial?.isDoubleSided = true
        geometry.firstMaterial?.reflective.contents = NSImage(named: "envmap")
        geometry.firstMaterial?.reflective.intensity = 0.3

        return geometry
    }

    func attributedString(with string: String) -> NSAttributedString {
        let font = NSFont(name: "Avenir Next Heavy", size:288)
        let attributes: [String : Any] = [NSFontAttributeName : font!]
        return NSMutableAttributedString(string: string,
                                         attributes: attributes)
    }

    func textFrontMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.black
        material.reflective.contents = NSImage(named: "envmap")
        material.reflective.intensity = 0.5
        material.multiply.contents = NSImage(named: "gradient2")
        return material
    }

    func textSideAndChamferMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.white
        material.reflective.contents = NSImage(named: "envmap")
        material.reflective.intensity = 0.4
        return material
    }

    func textChamferProfile() -> NSBezierPath {
        let profile = NSBezierPath()
        profile.move(to: NSMakePoint(0, 1))
        profile.line(to: NSMakePoint(1.5, 1))
        profile.line(to: NSMakePoint(1.5, 0))
        profile.line(to: NSMakePoint(1, 0))
        return profile
    }

    
    func starPath(innerRadius: CGFloat,
                  outerRadius: CGFloat) -> NSBezierPath {

        let raysCount = 5
        let delta = 2.0 * CGFloat.pi / CGFloat(raysCount)
        
        let path = NSBezierPath()
        
        for i in 0..<raysCount {
            var alpha = CGFloat(i) * delta + CGFloat.pi/2

            if (i == 0) {
                path.move(to: NSMakePoint(outerRadius * cos(alpha),
                                          outerRadius * sin(alpha)))
            }
            else {
                path.line(to: NSMakePoint(outerRadius * cos(alpha),
                                          outerRadius * sin(alpha)))
            }

            alpha += 0.5 * delta
            path.line(to: NSMakePoint(innerRadius * cos(alpha),
                                      innerRadius * sin(alpha)))
        }

        return path
    }

    // the curve to use to extrude the shape
    func chamferProfileForOutline() -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: NSMakePoint(1, 1))
        path.line(to: NSMakePoint(1, 0))
        return path
    }

}
