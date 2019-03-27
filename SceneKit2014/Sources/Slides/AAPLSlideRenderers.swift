/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Presents the three possibilities that SceneKit offers to render a scene.
*/

import SceneKit

// slide #12
class AAPLSlideRenderers: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Displaying the Scene")

        // Add labels
        var node = SCNNode.asc_labelNode(withString: "SCNView",
                                         size: .normal,
                                         isLit: false)
        node.position = SCNVector3Make(-14, 8, 0)
        self.contentNode.addChildNode(node)

        node = SCNNode.asc_labelNode(withString: "SCNLayer\n(OS X only)",
                                     size: .normal,
                                     isLit: false)
        node.position = SCNVector3Make(-2.2, 7, 0)
        self.contentNode.addChildNode(node)

        node = SCNNode.asc_labelNode(withString: "SCNRenderer",
                                     size: .normal,
                                     isLit: false)
        node.position = SCNVector3Make(9.5, 8, 0)
        self.contentNode.addChildNode(node)

        // Add images - SCNView
        var box = SCNNode.asc_planeNode(withImageNamed: "renderer-window",
                                        size: 8,
                                        isLit: false)
        box.position = SCNVector3Make(-10, 3, 5)
        self.contentNode.addChildNode(box)

        box = SCNNode.asc_planeNode(withImageNamed: "teapot",
                                    size: 6,
                                    isLit: false)
        box.position = SCNVector3Make(-10, 3, 5.1);
            self.contentNode.addChildNode(box)

        // Add images - SCNLayer
        box = SCNNode.asc_planeNode(withImageNamed: "renderer-layer",
                                    size: 7.4,
                                    isLit: false)
        box.position = SCNVector3Make(0, 3.5, 5)
        box.rotation = SCNVector4Make(0, 0, 1,
                                      CGFloat.pi / 20)
        self.contentNode.addChildNode(box)

        box = SCNNode.asc_planeNode(withImageNamed: "teapot",
                                    size: 6,
                                    isLit: false)
        box.position = SCNVector3Make(0, 3.5, 5.1)
        box.rotation = SCNVector4Make(0, 0, 1,
                                      CGFloat.pi / 20)
        self.contentNode.addChildNode(box)

        // Add images - SCNRenderer
        box = SCNNode.asc_planeNode(withImageNamed: "renderer-framebuffer",
                                    size: 8,
                                    isLit: false)
        box.position = SCNVector3Make(10, 3.2, 5)
        self.contentNode.addChildNode(box)

        box = SCNNode.asc_planeNode(withImageNamed: "teapot",
                                    size: 6,
                                    isLit: false)
        box.position = SCNVector3Make(10, 3, 5.1)
        self.contentNode.addChildNode(box)
    }
}
