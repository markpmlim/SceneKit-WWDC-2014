/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Chapter 5 slide

*/
import SceneKit

// slide #37 
class AAPLSlideChapter5: APPLSlide {
    var footPrintNode: SCNNode?

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(chapterTitle: "Rendering")
    }

    // handles pre-early exit from a slide presentation
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        footPrintNode?.removeFromParentNode()
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        //add footprint
        footPrintNode = SCNNode()

        let presenter = self.textManager.add(text: "Aymeric Bard",
                                             at :0)
        let title = self.textManager.add(footPrint: "Software Engineer")
        let footPrint = self.textManager.add(footPrint: "")

        presenter.renderingOrder = 100
        title.renderingOrder = 100
        title.geometry?.firstMaterial = footPrint.geometry?.firstMaterial
        presenter.geometry?.firstMaterial?.readsFromDepthBuffer = false
        title.geometry?.firstMaterial?.readsFromDepthBuffer = false

        presenter.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+1.38, footPrint.position.z);
        title.position = SCNVector3Make(footPrint.position.x, footPrint.position.y+0.93, footPrint.position.z);

        let SCALE: CGFloat = 0.007
        let scale = SCNVector3Make(SCALE, SCALE, SCALE)
        presenter.scale = scale
        title.scale = scale

        footPrintNode?.addChildNode(presenter)
        footPrintNode?.addChildNode(footPrint)
        footPrintNode?.addChildNode(title)

        footPrintNode?.opacity = 0

        presentationViewController.cameraNode?.addChildNode(footPrintNode!)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        footPrintNode?.opacity = 1.0
        SCNTransaction.commit()
    }
}
