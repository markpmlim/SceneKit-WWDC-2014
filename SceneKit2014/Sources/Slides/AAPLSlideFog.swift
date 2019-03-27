/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Explains how to render fog.

*/
import SceneKit

// slide #49
class AAPLSlideFog: APPLSlide {
    var backgroundNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 3
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and add some text
        _ = self.textManager.set(title: "Fog")
        _ = self.textManager.set(subtitle: "SCNScene")
        
        self.textManager.addEmptyLine()
        _ = self.textManager.add(code: "// set some fog\n" +
                                        "aScene.#fogColor# = aColor;\n" +
                                        "aScene.#fogStartDistance# = 50;\n" +
                                        "aScene.#fogEndDistance# = 100;")


        //add palm trees
        var palmTree = self.groundNode.asc_addChildNode(named: "PalmTree",
                                                        fromSceneNamed: "Scenes.scnassets/palmTree/palm_tree",
                                                        withScale: 15)
        palmTree.position = SCNVector3Make(4, -1, 0)

        palmTree = palmTree.clone()
        self.groundNode.addChildNode(palmTree)
        palmTree.position = SCNVector3Make(0, -1, 7)

        palmTree = palmTree.clone()
        self.groundNode.addChildNode(palmTree)
        palmTree.position = SCNVector3Make(8, -1, 13)

        palmTree = palmTree.clone()
        self.groundNode.addChildNode(palmTree)
        palmTree.position = SCNVector3Make(13, -1, -7)

        palmTree = palmTree.clone()
        self.groundNode.addChildNode(palmTree)
        palmTree.position = SCNVector3Make(-13, -1, -14)

        palmTree = palmTree.clone()
        self.groundNode.addChildNode(palmTree)
        palmTree.position = SCNVector3Make(3, -1, -14)
    }
    
    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0

        switch(stepIndex){
        case 0:
            break
        case 1:
            //add a plane in the background
            do {
                self.textManager.fadeOutText(ofTextType: .code)
                self.textManager.fadeOutText(ofTextType: .subtitle)

                let bg = SCNNode()
                let plane = SCNPlane(width: 100, height:100)
                bg.geometry = plane
                bg.position = SCNVector3Make(0, 0, -60)
                presentationViewController.cameraNode?.addChildNode(bg)

                backgroundNode = bg

                presentationViewController.presentationView.scene?.fogColor = NSColor.white
                presentationViewController.presentationView.scene?.fogStartDistance = 10
                presentationViewController.presentationView.scene?.fogEndDistance = 50
            }
        case 2:
            presentationViewController.presentationView.scene?.fogDensityExponent = 0.3
        default:
            break
        }
        SCNTransaction.commit()
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.completionBlock = {
            self.backgroundNode?.removeFromParentNode()
        }
        presentationViewController.presentationView.scene?.fogColor = NSColor.black
        presentationViewController.presentationView.scene?.fogEndDistance = 45.0
        presentationViewController.presentationView.scene?.fogDensityExponent = 1.0
        presentationViewController.presentationView.scene?.fogStartDistance = 40.0
        SCNTransaction.commit()
    }
}
