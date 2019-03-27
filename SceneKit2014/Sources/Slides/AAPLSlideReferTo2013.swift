/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Chapter 2 slide : Scene Graph
*/


import SceneKit

// slide #3
class AAPLSlideReferTo2013: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Related Sessions")

        // load the "related.png" image and show it mapped on a plane
        let relatedImage = SCNNode.asc_planeNode(withImageNamed: "related.png",
                                                 size: 35,
                                                 isLit: false)
        relatedImage.position = SCNVector3Make(0, 10, 0)
        relatedImage.castsShadow = false
        self.groundNode.addChildNode(relatedImage)
    }
}
