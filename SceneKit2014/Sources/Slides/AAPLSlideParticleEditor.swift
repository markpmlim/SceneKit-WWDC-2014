/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Introduces the built-in particle editor of XCode.
*/

import SceneKit

// slide #47
class AAPLSlideParticleEditor: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Add some text
        _ = self.textManager.set(title: "3D Particle Editor")

        _ = self.textManager.add(bullet:"Integrated into Xcode",
                                 at: 0)
        _ = self.textManager.add(bullet:"Edit .scnp files",
                                 at: 0)
        _ = self.textManager.add(bullet:"Particle templates available",
                                 at: 0)
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        // Bring up a screenshot of the editor
        let editorScreenshotNode = SCNNode.asc_planeNode(withImageNamed: "particleEditor",
                                                         size: 14,
                                                         isLit: true)
        editorScreenshotNode.geometry?.firstMaterial?.diffuse.mipFilter = .linear;
        editorScreenshotNode.position = SCNVector3Make(17, 3.8, 5)
        editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0,
                                                       -CGFloat.pi / 1.5)
        self.groundNode.addChildNode(editorScreenshotNode)

        // Animate it (rotate and move)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            editorScreenshotNode.position = SCNVector3Make(7, 3.8, 5)
            editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0,
                                                           -CGFloat.pi / 7.0)
        }
        SCNTransaction.commit()
    }
}
