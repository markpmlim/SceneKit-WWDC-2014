/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Explains what the depth of field effect is and shows an example.

*/

import SceneKit

// slide #50
class AAPLSlideDOF: APPLSlide {
    var _pivot: SCNNode?
    var _camera: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle
        _ = self.textManager.set(title: "Depth of Field")
        _ = self.textManager.set(subtitle: "SCNCamera")

        // Create a node that will contain the chess board
        let intermediateNode = SCNNode()
        intermediateNode.scale = SCNVector3Make(35.0, 35.0, 35.0)
        intermediateNode.position = SCNVector3Make(0, 0, 2.1)
        self.contentNode.addChildNode(intermediateNode)

        _pivot = SCNNode()
        intermediateNode.addChildNode(_pivot!)

        // Load the chess model and add to "intermediateNode"
        _ = intermediateNode.asc_addChildNode(named: "Line01",
                                              fromSceneNamed: "Scenes.scnassets/chess/chess",
                                              withScale: 1)
    }
    
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        let cameraNode = presentationViewController.cameraNode
        switch (stepIndex) {
        case 0:
            break
        case 1:
            // Add a code snippet
            _ = self.textManager.add(code: "aCamera.#focalDistance# = 16.0; \n" +
                                            "aCamera.#focalBlurRadius# = 8.0;")
        case 2:
            do {
                // Turn on DOF to illustrate the code snippet
                cameraNode?.camera?.focalDistance = 16
                cameraNode?.camera?.focalSize = 1.5
                cameraNode?.camera?.aperture = 0.3
                cameraNode?.camera?.focalBlurRadius = 8
            }
        case 3:
            // Focus far away
            cameraNode?.camera?.focalDistance = 35
            cameraNode?.camera?.focalSize = 4
            cameraNode?.camera?.aperture = 0.1
            
            // and update the code snippet
            self.textManager.fadeOutText(ofTextType: .code)
            _ = self.textManager.add(code:
                    "aCamera.#focalDistance# = #35.0#; \n" +
                    "aCamera.#focalBlurRadius# = 8.0;")
        default:
            break
        }
        SCNTransaction.commit()
    }


    // handles pre-early exit from a slide presentation
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        // Restore camera settings before leaving this slide
        presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode
        presentationViewController.presentationView.pointOfView?.camera?.focalBlurRadius = 0
    }
}
