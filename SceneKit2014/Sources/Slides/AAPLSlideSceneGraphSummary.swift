/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Recaps the structure of the scene graph with an example.
*/

import SceneKit

// slide #9
class AAPLSlideSceneGraphSummary: APPLSlide {
    var sunNode: SCNNode?
    var sunHaloNode: SCNNode?
    var earthNode: SCNNode?
    var earthGroupNode: SCNNode?
    var moonNode: SCNNode?
    var wireframeBoxNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 6
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            // Set the slide's title and subtitle
            _ = self.textManager.set(title: "Scene Graph")
            _ = self.textManager.set(subtitle: "Summary")
        case 1:
            do {
                // A node that will help visualize the position of the stars
                wireframeBoxNode = SCNNode()
                wireframeBoxNode?.rotation = SCNVector4Make(0, 1, 0,
                                                            CGFloat.pi/4)
                wireframeBoxNode?.geometry = SCNBox(width: 1,
                                                    height: 1,
                                                    length: 1,
                                                    chamferRadius: 0)
                wireframeBoxNode?.geometry?.firstMaterial!.diffuse.contents = NSImage(named: "box_wireframe")
                wireframeBoxNode?.geometry?.firstMaterial!.lightingModel = .constant    // no lighting
                wireframeBoxNode?.geometry?.firstMaterial!.isDoubleSided = true         // double sided

                // Sun
                sunNode = SCNNode()
                sunNode?.position = SCNVector3Make(0, 30, 0)
                self.contentNode.addChildNode(sunNode!)
                sunNode?.addChildNode(wireframeBoxNode!.copy() as! SCNNode)

                // Earth-rotation (center of rotation of the Earth around the Sun)
                let earthRotationNode = SCNNode()
                sunNode?.addChildNode(earthRotationNode)

                // Earth-group (will contain the Earth, and the Moon)
                earthGroupNode = SCNNode()
                earthGroupNode?.position = SCNVector3Make(15, 0, 0)
                earthRotationNode.addChildNode(earthGroupNode!)

                // Earth
                earthNode = wireframeBoxNode?.copy() as? SCNNode
                earthNode?.position = SCNVector3Make(0, 0, 0)
                earthGroupNode?.addChildNode(earthNode!)
                
                // Rotate the Earth around the Sun
                var animation = CABasicAnimation(keyPath: "rotation")
                animation.duration = 10.0
                animation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       (CGFloat.pi * 2.0)))
                animation.repeatCount = .greatestFiniteMagnitude
                earthRotationNode.addAnimation(animation,
                                               forKey: "earth rotation around sun")

                // Rotate the Earth on its own-axis
                animation = CABasicAnimation(keyPath: "rotation")
                animation.duration = 1.0
                animation.fromValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0.0))
                animation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       (CGFloat.pi * 2.0)))
                animation.repeatCount = .greatestFiniteMagnitude
                earthNode?.addAnimation(animation,
                                        forKey: "earth rotation")
            }
        case 2:
            do {
                // Moon-rotation (center of rotation of the Moon around the Earth)
                let moonRotationNode = SCNNode()
                earthGroupNode?.addChildNode(moonRotationNode)

                // Moon
                moonNode = wireframeBoxNode?.copy() as! SCNNode?
                moonNode?.position = SCNVector3Make(5, 0, 0)
                moonRotationNode.addChildNode(moonNode!)

                // Rotate the moon around the Earth
                var animation = CABasicAnimation(keyPath: "rotation")
                animation.duration = 1.5;
                animation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       (CGFloat.pi * 2.0)))
                animation.repeatCount = .greatestFiniteMagnitude;
                moonRotationNode.addAnimation(animation,
                                              forKey: "moon rotation around earth");

                // Rotate the moon
                animation = CABasicAnimation(keyPath: "rotation")
                animation.duration = 1.5
                animation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       (CGFloat.pi * 2.0)))
                animation.repeatCount = .greatestFiniteMagnitude;
                moonNode?.addAnimation(animation, forKey: "moon rotation")
            }
        case 3:
            do {
                // Add geometries (spheres) to represent the stars
                sunNode?.geometry = SCNSphere(radius:2.5)
                earthNode?.geometry = SCNSphere(radius:1.5)
                moonNode?.geometry = SCNSphere(radius: 0.75)

                // Add a textured plane to represent Earth's orbit
                let earthOrbit = SCNNode()
                earthOrbit.opacity = 0.4
                earthOrbit.geometry = SCNPlane(width:31, height:31)
                earthOrbit.geometry?.firstMaterial!.diffuse.contents =  "Scenes.scnassets/earth/orbit.png"
                earthOrbit.geometry?.firstMaterial!.diffuse.mipFilter =  .linear
                earthOrbit.rotation = SCNVector4Make(1, 0, 0,
                                                     -CGFloat.pi/2)
                earthOrbit.geometry?.firstMaterial!.lightingModel = .constant // no lighting
                sunNode?.addChildNode(earthOrbit)
            }
        case 4:
            do {
                // Add a halo to the Sun (a simple textured plane that does not write to depth)
                sunHaloNode = SCNNode()
                sunHaloNode?.geometry = SCNPlane(width: 30, height: 30)
                sunHaloNode?.rotation = SCNVector4Make(1, 0, 0,
                                                       self.pitch * (CGFloat.pi / 180.0))
                sunHaloNode?.geometry?.firstMaterial!.diffuse.contents = "Scenes.scnassets/earth/sun-halo.png"
                sunHaloNode?.geometry?.firstMaterial!.lightingModel = .constant     // no lighting
                sunHaloNode?.geometry?.firstMaterial!.writesToDepthBuffer = false   // do not write to depth
                sunHaloNode?.opacity = 0.2
                sunNode?.addChildNode(sunHaloNode!)

                // Add materials to the planets
                earthNode?.geometry?.firstMaterial!.diffuse.contents = "Scenes.scnassets/earth/earth-diffuse-mini.jpg"
                earthNode?.geometry?.firstMaterial!.emission.contents = "Scenes.scnassets/earth/earth-emissive-mini.jpg"
                earthNode?.geometry?.firstMaterial!.specular.contents = "Scenes.scnassets/earth/earth-specular-mini.jpg"
                moonNode?.geometry?.firstMaterial!.diffuse.contents = "Scenes.scnassets/earth/moon.jpg"
                sunNode?.geometry?.firstMaterial!.multiply.contents = "Scenes.scnassets/earth/sun.jpg"
                sunNode?.geometry?.firstMaterial!.diffuse.contents = "Scenes.scnassets/earth/sun.jpg"
                sunNode?.geometry?.firstMaterial!.multiply.intensity = 0.5
                sunNode?.geometry?.firstMaterial!.lightingModel = .constant

                sunNode?.geometry?.firstMaterial!.multiply.wrapS = .repeat
                sunNode?.geometry?.firstMaterial!.diffuse.wrapS  = .repeat
                sunNode?.geometry?.firstMaterial!.multiply.wrapT = .repeat
                sunNode?.geometry?.firstMaterial!.diffuse.wrapT  = .repeat

                earthNode?.geometry?.firstMaterial!.locksAmbientWithDiffuse = true
                moonNode?.geometry?.firstMaterial!.locksAmbientWithDiffuse  = true
                sunNode?.geometry?.firstMaterial!.locksAmbientWithDiffuse   = true

                earthNode?.geometry?.firstMaterial!.shininess = 0.1
                earthNode?.geometry?.firstMaterial!.specular.intensity = 0.5
                moonNode?.geometry?.firstMaterial!.specular.contents = NSColor.gray

                // Achieve a lava effect by animating textures
                var animation = CABasicAnimation(keyPath: "contentsTransform")
                animation.duration = 10.0
                animation.fromValue = NSValue(caTransform3D: CATransform3DConcat(SCNMatrix4MakeTranslation(0, 0, 0),
                                                                                 SCNMatrix4MakeScale(3, 3, 3)))
                animation.toValue = NSValue(caTransform3D: CATransform3DConcat(SCNMatrix4MakeTranslation(1, 0, 0),
                                                                               SCNMatrix4MakeScale(3, 3, 3)))
                animation.repeatCount = .greatestFiniteMagnitude
                sunNode?.geometry?.firstMaterial!.diffuse.addAnimation(animation,
                forKey: "sun-texture")

                animation = CABasicAnimation(keyPath: "contentsTransform")
                animation.duration = 30.0
                animation.fromValue = NSValue(caTransform3D: CATransform3DConcat(SCNMatrix4MakeTranslation(0, 0, 0),
                                                                                 SCNMatrix4MakeScale(5, 5, 5)))
                animation.toValue = NSValue(caTransform3D: CATransform3DConcat(SCNMatrix4MakeTranslation(1, 0, 0),
                                                                               SCNMatrix4MakeScale(5, 5, 5)))

                animation.repeatCount = .greatestFiniteMagnitude
                sunNode?.geometry?.firstMaterial!.multiply.addAnimation(animation,
                forKey: "sun-texture2")
            }
        case 5:
            do {
                // We will turn off all the lights in the scene and add a new light
                // to give the impression that the Sun lights the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light?.color = NSColor.black  // initially switched off
                lightNode.light?.type = .omni
                sunNode?.addChildNode(lightNode)

                // Configure attenuation distances because we don't want to light the floor
                lightNode.light?.attenuationEndDistance = 20.0
                lightNode.light?.attenuationStartDistance = 19.5

                // Animation
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    //switch off all the other lights
                    presentationViewController.updateLighting(withIntensities: [0.0])
                    lightNode.light?.color = NSColor.white  // switch on
                    sunHaloNode?.opacity = 0.5              // make the halo stronger
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
}
