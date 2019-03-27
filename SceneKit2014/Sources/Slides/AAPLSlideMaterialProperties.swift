/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates how the different material properties affect the appearance of an object.
*/

import SceneKit

// slide #39
class AAPLSlideMaterialProperties: APPLSlide {
    var _earthNode: SCNNode?
    var _cloudsNode: SCNNode?

    var _cameraOriginalPosition: SCNVector3?

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Material Properties")

        _ = self.textManager.add(bullet: "Diffuse",
                                 at: 0)
        _ = self.textManager.add(bullet: "Ambient",
                                 at: 0)
        _ = self.textManager.add(bullet: "Specular",
                                 at: 0)
        _ = self.textManager.add(bullet: "Normal",
                                 at: 0)
        _ = self.textManager.add(bullet: "Reflective",
                                 at: 0)
        _ = self.textManager.add(bullet: "Emission",
                                 at: 0)
        _ = self.textManager.add(bullet: "Transparent",
                                 at: 0)
        _ = self.textManager.add(bullet: "Multiply",
                                 at: 0)

        var imageNode = SCNNode.asc_planeNode(withImageNamed: "earth-diffuse-mini.jpg",
                                              size: 3.0,
                                              isLit: false)
        imageNode.position = SCNVector3Make(-7, 12.7, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)

        imageNode = SCNNode.asc_planeNode(withImageNamed: "earth-specular-mini.jpg",
                                          size: 3.0,
                                          isLit: false)
        imageNode.position = SCNVector3Make(-7, 9.4, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)

        imageNode = SCNNode.asc_planeNode(withImageNamed: "earth-bump-mini.png",
                                          size: 3.0,
                                          isLit: false)
        imageNode.position = SCNVector3Make(-7, 7.5, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)

        imageNode = SCNNode.asc_planeNode(withImageNamed: "earth-emissive-mini.jpg",
                                          size: 3.0,
                                          isLit: false)
        imageNode.position = SCNVector3Make(-7, 4.5, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)

        imageNode = SCNNode.asc_planeNode(withImageNamed: "cloudsTransparency-mini.png",
                                          size: 3.0,
                                          isLit: false)
        imageNode.position = SCNVector3Make(-7, 2.8, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)

        // Create a node for Earth and another node to display clouds
        _earthNode = SCNNode()
        _earthNode?.position = SCNVector3Make(6, 7.2, -2)
        _earthNode?.geometry = SCNSphere(radius: 7.2)

        _cloudsNode = SCNNode()
        _cloudsNode?.geometry = SCNSphere(radius: 7.9)

        self.groundNode.addChildNode(_earthNode!)
        _earthNode?.addChildNode(_cloudsNode!)

        // Initially hide everything
        _earthNode?.opacity = 1.0
        _cloudsNode?.opacity = 0.5

        _earthNode?.geometry?.firstMaterial?.ambient.intensity = 1
        _earthNode?.geometry?.firstMaterial?.normal.intensity = 1
        _earthNode?.geometry?.firstMaterial?.reflective.intensity = 0.2
        _earthNode?.geometry?.firstMaterial?.reflective.contents = NSColor.white
        _earthNode?.geometry?.firstMaterial?.fresnelExponent = 3.0


        _earthNode?.geometry?.firstMaterial?.emission.intensity = 1
        _earthNode?.geometry?.firstMaterial?.diffuse.contents = "Scenes.scnassets/earth/earth-diffuse.jpg"

        _earthNode?.geometry?.firstMaterial?.shininess = 0.1
        _earthNode?.geometry?.firstMaterial?.specular.contents = "Scenes.scnassets/earth/earth-specular.jpg"
        _earthNode?.geometry?.firstMaterial?.specular.intensity = 0.8

        _earthNode?.geometry?.firstMaterial?.normal.contents = "Scenes.scnassets/earth/earth-bump.png"
        _earthNode?.geometry?.firstMaterial?.normal.intensity = 1.3

        _earthNode?.geometry?.firstMaterial?.emission.contents = "Scenes.scnassets/earth/earth-emissive.jpg";
        //_earthNode?.geometry?.firstMaterial?.reflective.intensity = 0.3;
        _earthNode?.geometry?.firstMaterial?.emission.intensity = 1.0;


        // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
        _cloudsNode?.geometry?.firstMaterial?.transparent.contents = "Scenes.scnassets/earth/cloudsTransparency.png";
        _cloudsNode?.geometry?.firstMaterial?.transparencyMode = .rgbZero
        
        // Use a shader modifier to display an environment map independently of the lighting model used
        _earthNode?.geometry?.shaderModifiers = [ .fragment :
            " _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;" +
            "_output.color.rgb += _surface.reflective.rgb;"]

        // Add animations
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.duration = 40.0;
        rotationAnimation.repeatCount = .greatestFiniteMagnitude;
        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       CGFloat.pi * 2))
        _earthNode?.addAnimation(rotationAnimation,
                                 forKey: nil)
        rotationAnimation.duration = 100.0
        _cloudsNode?.addAnimation(rotationAnimation,
                                  forKey: nil)


        //animate light
        let lightHandleNode = SCNNode()
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.castsShadow = true
        lightHandleNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                             y: -CGFloat.pi*2,
                                                                             z: 0,
                                                                             duration: 12)))
        lightHandleNode.addChildNode(lightNode)

        _earthNode?.addChildNode(lightHandleNode)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        switch (stepIndex) {
        case 0:
            break;
        default:
            break
        }
        SCNTransaction.commit()
    }
}
