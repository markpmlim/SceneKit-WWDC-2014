/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustrates the light attribute.
*/

import SceneKit

// slide #7
class AAPLSlideLight: APPLSlide {
    var _lightNode: SCNNode?
    var _lightOffImageNode: SCNNode?
    var _lightOnImageNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 2
    }
    
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        switch (stepIndex) {
        case 0:
            do {
                // Set the slide's title and subtitle and add some text
                _ = self.textManager.set(title: "Node Attributes")
                _ = self.textManager.set(subtitle: "SCNLights")

                _ = self.textManager.add(bullet: "Four light types",
                                         at: 0)
                _ = self.textManager.add(bullet: "Omni",
                                         at: 1)
                _ = self.textManager.add(bullet: "Directional",
                                         at: 1)
                _ = self.textManager.add(bullet: "Spot",
                                         at: 1)
                _ = self.textManager.add(bullet: "Ambient",
                                         at: 1)

                // Add some code
                let codeExampleNode = self.textManager.add(code: "aNode.#light#       = [SCNLight light]; \n" +
                        "aNode.light.color = [UIColor whiteColor];")

                codeExampleNode.position = SCNVector3Make(12, 7, 1)

                // Add a light to the scene
                _lightNode = SCNNode()
                _lightNode?.light = SCNLight()
                _lightNode?.light?.type = .omni;
                _lightNode?.light?.color = NSColor.black        // initially off
                _lightNode?.light?.attenuationStartDistance = 30
                _lightNode?.light?.attenuationEndDistance = 40
                _lightNode?.position = SCNVector3Make(5, 3.5, 0)
                self.contentNode.addChildNode(_lightNode!)

                // Load two images to help visualize the light (on and off)
                _lightOffImageNode = SCNNode.asc_planeNode(withImageNamed: "light-off",
                                                           size: 7,
                                                           isLit: true)
                _lightOnImageNode = SCNNode.asc_planeNode(withImageNamed: "light-on",
                                                          size: 7,
                                                          isLit: true)
                _lightOnImageNode?.opacity = 0.0
                _lightOnImageNode?.castsShadow = false
                _lightOffImageNode?.castsShadow = false
                
                _lightNode?.addChildNode(_lightOnImageNode!)
                _lightNode?.addChildNode(_lightOffImageNode!)
            }
        case 1:
            do {
                // Switch the light on
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    _lightNode?.light?.color = NSColor(calibratedRed: 1,
                                                       green: 1,
                                                       blue: 0.8,
                                                       alpha: 1)
                    _lightOnImageNode?.opacity = 1.0
                    _lightOffImageNode?.opacity = 0.0
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
        SCNTransaction.commit()
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        do {
            // Switch the light off
            _lightNode?.light = nil
        }
        SCNTransaction.commit()
    }
}
