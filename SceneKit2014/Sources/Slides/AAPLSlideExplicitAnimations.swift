/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Explains how explicit animations work and shows an example.

*/

import SceneKit

// slide #27
class AAPLSlideExplicitAnimations: APPLSlide {
    var _animatedNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 5
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some code
        _ = self.textManager.set(title: "Animations")
        _ = self.textManager.set(subtitle: "Explicit animations")

        _ = self.textManager.add(code: "// Create an animation \n" +
            "animation = [#CABasicAnimation# animationWithKeyPath:@\"rotation\"]; \n\n" +
            "// Configure the animation \n" +
            "animation.#duration# = 2.0; \n" +
            "animation.#toValue# = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)]; \n" +
            "animation.#repeatCount# = MAXFLOAT; \n\n" +
            "// Play the animation \n" +
            "[aNode #addAnimation:#animation #forKey:#@\"myAnimation\"];")

        // A simple torus that we will animate to illustrate the code
        _animatedNode = SCNNode()
        _animatedNode?.position = SCNVector3Make(9, 5.7, 20)

        // Use an extra node that we can tilt it and cumulate that with the animation
        let torusNode = SCNNode()
        torusNode.geometry = SCNTorus(ringRadius: 4.0,
                                      pipeRadius: 1.5)
        torusNode.rotation = SCNVector4Make(1, 0, 0,
                                            -CGFloat.pi * 0.5)
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

            // Initially hide the torus
            _animatedNode?.opacity = 0.0
            self.textManager.highlight(codeChunks: [NSNumber]())    // empty array
        case 1:
            self.textManager.highlight(codeChunks: [0])
        case 2:
            self.textManager.highlight(codeChunks: [1, 2, 3])       // 3 elements
        case 3:
            self.textManager.highlight(codeChunks: [4, 5])
        case 4:
            do {
                SCNTransaction.animationDuration = 0

                // Show the torus
                _animatedNode?.opacity = 1.0;
                // Animate explicitly
                let animation = CABasicAnimation(keyPath: "rotation")
                animation.duration = 2.0
                animation.toValue = NSValue(scnVector4: SCNVector4Make(0, 1, 0,
                                                                       CGFloat.pi * 2))
                animation.repeatCount = .greatestFiniteMagnitude
                _animatedNode?.addAnimation(animation,
                                            forKey: "myAnimation")
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    // Dim the text
                    self.textManager.textNode.opacity = 0.75

                    presentationViewController.cameraHandle?.position = (presentationViewController.cameraHandle?.convertPosition(SCNVector3Make(9, 8, 20),
                                                                                                                                  to: presentationViewController.cameraHandle?.parent))!
                    presentationViewController.cameraPitch?.rotation = SCNVector4Make(1, 0, 0,
                                                                                     (-CGFloat.pi / 10))
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
        SCNTransaction.commit()
    }
}
