/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Performance tips when dealing with lights.
*/


import SceneKit

// slide #57
class AAPLSlideLighting: APPLSlide {
    var _roomNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Performance")
        _ = self.textManager.set(subtitle: "Lighting")
        
        _ = self.textManager.add(bullet: "Minimize the number of lights",
                                 at: 0)
        _ = self.textManager.add(bullet: "Prefer static than dynamic shadows",
                                 at: 0)
        _ = self.textManager.add(bullet: "Use material's \"multiply\" property",
                                 at: 0)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 1:
            do {
                // Load the scene
                let intermediateNode = SCNNode()
                intermediateNode.position = SCNVector3Make(0.0, 0.1, -24.5)
                _roomNode = intermediateNode.asc_addChildNode(named: "Mesh",
                                                              fromSceneNamed: "Scenes.scnassets/cornell-box/cornell-box.dae",
                                                              withScale: 15)
                self.contentNode.addChildNode(intermediateNode)

                // Hide the light maps for now
                for material in (_roomNode?.geometry?.materials)! {
                    material.multiply.intensity = 0.0;
                    material.lightingModel = .blinn;
                }

                // Animate the point of view with an implicit animation.
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 2.0

                SCNTransaction.completionBlock = {

                    //animate the object
                    intermediateNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                                          y: (2*CGFloat.pi),
                                                                                          z: 0,
                                                                                          duration: 10)))
                    }

                do {
                    presentationViewController.cameraHandle?.position = (presentationViewController.cameraHandle?.convertPosition(SCNVector3Make(0, +5, -30),
                                                                                                                                  to: presentationViewController.cameraHandle?.parent))!
                    presentationViewController.cameraPitch?.rotation = SCNVector4Make(1, 0, 0,
                                                                                      -CGFloat.pi/4 * 0.2)
                }
                SCNTransaction.commit()
            }
        case 2:
            do {
                // Remove the lighting by using a constant lighing model (no lighting)
                for material in (_roomNode?.geometry?.materials)! {
                    material.lightingModel = .constant
                }
            }
        case 3:
            do {
                // Activate the light maps smoothly
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    for material in (_roomNode?.geometry?.materials)! {
                        material.multiply.intensity = 1.0
                    }
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
}
