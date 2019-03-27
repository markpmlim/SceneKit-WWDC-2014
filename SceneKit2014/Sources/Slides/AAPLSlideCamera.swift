/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Camera slide. Illustrates the camera node attribute.

*/

import SceneKit

// slide #8
class AAPLSlideCamera: APPLSlide {

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 4
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Create a node to own the "sign" model, make it to be close to the camera,
        // rotate by 90 degrees because it's oriented with z-axis as the up axis
        let intermediateNode = SCNNode()
        intermediateNode.position = SCNVector3Make(0, 0, 7)
        self.groundNode.addChildNode(intermediateNode)

        // Load the "sign" model
        let signNode = intermediateNode.asc_addChildNode(named: "sign",
                                                         fromSceneNamed: "Scenes.scnassets/intersection/intersection",
                                                         withScale: 10)
        signNode.position = SCNVector3Make(4, 0, 0.05)

        // Re-parent every node that holds a camera otherwise they would inherit the scale from the "sign" model.
        // This is not a problem except that the scale affects the zRange of cameras and so it would be harder to
        // get the transition from one camera to another right.
        let cameraNodes = signNode.childNodes(passingTest: {
            (child: SCNNode, stop: UnsafeMutablePointer<ObjCBool>) in
            return (child.camera != nil)
        })

        for cameraNode in cameraNodes {
            let previousWorldTransform = cameraNode.worldTransform
            intermediateNode.addChildNode(cameraNode) // re-parent
            cameraNode.transform = intermediateNode.convertTransform(previousWorldTransform,
                                                                     from: nil)     // world coord space
            cameraNode.scale = SCNVector3Make(1, 1, 1)
        }

        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Node Attributes")
        _ = self.textManager.set(subtitle: "SCNCamera")
        _ = self.textManager.add(bullet: "Point of view for renderers", at: 0)

        _ = self.textManager.add(code:
        "aNode.#camera# = [#SCNCamera# camera]; \n" +
        "aView.#pointOfView# = aNode;")
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        switch (stepIndex) {
        case 0:
            break
        case 1:
            // Switch to camera1
            SCNTransaction.animationDuration = 2.0
            presentationViewController.presentationView.pointOfView = self.contentNode.childNode(withName: "camera1",
                                                                                                   recursively: true)
        case 2:
            // Switch to camera2
            SCNTransaction.animationDuration = 2.0
            presentationViewController.presentationView.pointOfView = self.contentNode.childNode(withName: "camera2",
                                                                                                   recursively: true)
        case 3:
            do {
                // Switch back to the default camera
                SCNTransaction.animationDuration = 1.0
                presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode
            }
        default:
            break
        }
        SCNTransaction.commit()
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        do {
            // Restore the default point of view before leaving this slide
            presentationViewController.presentationView.pointOfView = presentationViewController.cameraNode
        }
        SCNTransaction.commit()
    }

}
