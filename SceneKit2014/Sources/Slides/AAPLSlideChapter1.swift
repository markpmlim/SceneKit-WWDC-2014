/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Chapter 1 slide

*/
import SceneKit

// slide #0
class AAPLSlideChapter1: APPLSlide {
    var footPrintNode: SCNNode?

    required init() {
        //print("initializing: AAPLSlideChapter1")
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        //print("setupSlide: AAPLSlideChapter1", presentationViewController)
        _ = self.textManager.set(chapterTitle: "What's New in SceneKit")

        //add footprint
        footPrintNode = SCNNode()

        let sessionID = self.textManager.add(text: "Session 609", at: 0)
        let presenter = self.textManager.add(text:"Thomas Goossens", at: 0)
        let title = self.textManager.add(footPrint: "Software Engineer")
        let footPrint = self.textManager.add(footPrint: "© 2014 Apple Inc. All rights reserved. Redistribution or public display not permitted without written permission from Apple.")

        sessionID.renderingOrder = 100
        presenter.renderingOrder = 100
        title.renderingOrder = 100
        sessionID.geometry?.firstMaterial = footPrint.geometry?.firstMaterial
        title.geometry?.firstMaterial = footPrint.geometry?.firstMaterial
        presenter.geometry?.firstMaterial?.readsFromDepthBuffer = false
        title.geometry?.firstMaterial?.readsFromDepthBuffer = false

        sessionID.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.78, footPrint.position.z);
        presenter.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.38, footPrint.position.z);
        title.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+0.93, footPrint.position.z);

        let SCALE: CGFloat = 0.007
        let scale = SCNVector3Make(SCALE, SCALE, SCALE)
        sessionID.scale = scale
        presenter.scale = scale
        title.scale = scale

        footPrintNode?.addChildNode(sessionID)
        footPrintNode?.addChildNode(presenter)
        footPrintNode?.addChildNode(footPrint)
        footPrintNode?.addChildNode(title)

        presentationViewController.cameraNode!.addChildNode(footPrintNode!)
    }

    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        footPrintNode?.removeFromParentNode()
    }
}
