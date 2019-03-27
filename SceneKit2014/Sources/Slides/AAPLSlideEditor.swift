/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Presents the Xcode SceneKit editor.

*/

import SceneKit

// slide #18
class AAPLSlideEditor: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and add some text
        _ = self.textManager.set(title: "SceneKit Editor")
        _ = self.textManager.add(bullet: "Built into Xcode",
                                 at: 0)
        _ = self.textManager.add(bullet: "Scene graph inspectio",
                                 at: 0)
        _ = self.textManager.add(bullet: "Rendering preview",
                                 at: 0)
        _ = self.textManager.add(bullet: "Adjust lighting and materials",
                                 at: 0)
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        // Bring up a screenshot of the editor
        let editorScreenshotNode = SCNNode.asc_planeNode(withImageNamed: "editor.png",
                                                         size: 14,
                                                         isLit: true)
        editorScreenshotNode.position = SCNVector3Make(17, 4.1, 5)
        editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0,
                                                       -CGFloat.pi / 1.5)
        self.groundNode.addChildNode(editorScreenshotNode)

        // Animate it (rotate and move)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            editorScreenshotNode.position = SCNVector3Make(7.5, 4.1, 5)
            editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0,
                                                           -CGFloat.pi / 6.0)
        }
        SCNTransaction.commit()
    }
}
