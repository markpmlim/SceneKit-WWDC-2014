/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how implicit animations work and shows an example.
*/


import SceneKit

// slide #26
class AAPLSlideImplicitAnimations: APPLSlide {
    var _animatedNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Animations")
        _ = self.textManager.set(subtitle: "Implicit animations")

        _ = self.textManager.add(code:
            "// Begin a transaction \n" +
            "[#SCNTransaction# begin]; \n" +
            "[#SCNTransaction# setAnimationDuration:2.0]; \n\n" +
            "// Change properties \n" +
            "aNode.#opacity# = 1.0; \n" +
            "aNode.#rotation# = SCNVector4(0, 1, 0, M_PI*4); \n\n" +
            "// Commit the transaction \n" +
            "[SCNTransaction #commit#];")

        // A simple torus that we will animate to illustrate the code
        _animatedNode = SCNNode()
        _animatedNode?.position = SCNVector3Make(10, 7, 0)

        // Use an extra node that we can tilt it and cumulate that with the animation
        let torusNode = SCNNode()
        torusNode.geometry = SCNTorus(ringRadius: 4.0,
                                      pipeRadius: 1.5)
        torusNode.rotation = SCNVector4Make(1, 0, 0,
                                            -CGFloat.pi * 0.7)
        torusNode.geometry?.firstMaterial?.diffuse.contents = NSColor.red
        torusNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        torusNode.geometry?.firstMaterial?.reflective.contents = NSImage(named: "envmap")
        torusNode.geometry?.firstMaterial?.fresnelExponent = 0.7
        
        _animatedNode?.addChildNode(torusNode)
        self.contentNode.addChildNode(_animatedNode!)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        // Animate by default
        SCNTransaction.begin()

        switch (stepIndex) {
        case 0:
            // Disable animations for first step
            SCNTransaction.animationDuration = 0

            // Initially dim the torus
            _animatedNode?.opacity = 0.25

            self.textManager.highlight(codeChunks: [NSNumber]())
        case 1:
            self.textManager.highlight(codeChunks: [0, 1])
        case 2:
            self.textManager.highlight(codeChunks: [2, 3])
        case 3:
            self.textManager.highlight(codeChunks: [4])
            
            // Animate implicitly
            SCNTransaction.animationDuration = 2.0
            _animatedNode?.opacity = 1.0
            _animatedNode?.rotation = SCNVector4Make(0, 1, 0,
                                                     CGFloat.pi * 4)
        default:
            break
        }
        SCNTransaction.commit()
    }
}
