/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Explains how flattening nodes can help with performance.

*/

import SceneKit

// slide #55
class AAPLSlideFlattening: APPLSlide {

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 2
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            do {
                // Set the slide's title and subtitle and add some text.
                _ = self.textManager.set(title: "Performance")
                _ = self.textManager.set(subtitle: "Flattening")
                
                _ = self.textManager.add(bullet: "Flatten node tree into single node",
                                         at: 0)
                _ = self.textManager.add(bullet: "Minimize draw calls",
                                         at: 0)

                _ = self.textManager.add(code: "// Flatten node hierarchy \n" +
                                "SCNNode *flattenedNode = [aNode #flattenedClone#];")
            }
        case 1:
            do {
                // Discard the text and show a 2D image.
                // Animate the image's position when it appears.
                
                self.textManager.flipOutText(ofTextType: .code)
                self.textManager.flipOutText(ofTextType: .bullet)
                
                let imageNode = SCNNode.asc_planeNode(withImageNamed: "flattening",
                                                      size:20,
                                                      isLit: false)
                imageNode.position = SCNVector3Make(0, 4.8, 16)
                self.groundNode.addChildNode(imageNode)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    imageNode.position = SCNVector3Make(0, 4.8, 8)
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
}
