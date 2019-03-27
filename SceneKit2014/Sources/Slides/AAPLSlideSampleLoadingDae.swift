/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Shows how to load a scene from a dae file.
*/

import SceneKit

// slide #19
class AAPLSlideSampleLoadingDae: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Loading a DAE")
        _ = self.textManager.set(subtitle: "Sample code")

        _ = self.textManager.add(code: "// Load a DAE \n" +
                    "SCNScene *scene = [SCNScene #sceneNamed:#@\"dungeon.dae\"];")

        let image = SCNNode.asc_planeNode(withImageNamed: "daeAsResource",
                                          size: 9,
                                          isLit: false)
        image.position = SCNVector3Make(0, 3.2, 7)
        self.groundNode.addChildNode(image)
    }
}
