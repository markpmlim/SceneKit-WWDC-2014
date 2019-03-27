/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Labs info.
*/

import SceneKit

// slide #61
class AAPLSlideLabs: APPLSlide {

    required init() {
        super.init()
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title
        _ = self.textManager.set(title: "Labs")

        let relatedImage = SCNNode.asc_planeNode(withImageNamed: "labs.png",
                                                 size: 35,
                                                 isLit: false)
        relatedImage.position = SCNVector3Make(0, 30, 0)
        relatedImage.castsShadow = false
        self.contentNode.addChildNode(relatedImage)
    }
}
