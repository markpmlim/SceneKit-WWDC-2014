/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Last slide.

*/

import SceneKit

// slide #62
class AAPLSlideEnd: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        let imageNode = SCNNode.asc_planeNode(withImageNamed: "wwdc.png",
                                              size:19,
                                              isLit: false)
        imageNode.position = SCNVector3Make(0, 30, 0)
        imageNode.castsShadow = false
        self.contentNode.addChildNode(imageNode)
    }
}
