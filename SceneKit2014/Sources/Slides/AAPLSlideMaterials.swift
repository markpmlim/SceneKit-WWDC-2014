/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains what a material is.
*/

import SceneKit

// slide #38
class AAPLSlideMaterials: APPLSlide {
    var _sceneKitDiagramNode: SCNNode?

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Add some text
        _ = self.textManager.set(title: "Materials")

        _ = self.textManager.add(bullet: "Determines the appearance of the geometry",
                                 at: 0)
        _ = self.textManager.add(bullet: "SCNMaterial",
                                 at: 0)
        _ = self.textManager.add(bullet: "Material properties",
                                 at: 0)

        _ = self.textManager.add(bullet: "SCNMaterialProperty",
                                 at: 1)
        _ = self.textManager.add(bullet: "Contents is a color or an image",
                                 at: 1)

        // Prepare the diagram but hide it for now
        _sceneKitDiagramNode = AAPLSlideSceneGraph.sharedScenegraphDiagramNode()
        AAPLSlideSceneGraph.scenegraphDiagramGoTo(step: 0)

        _sceneKitDiagramNode?.position = SCNVector3Make(3.0, 8.0, 0)
        _sceneKitDiagramNode?.opacity = 0.0

        self.contentNode.addChildNode(_sceneKitDiagramNode!)
    }

    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        // Reveal and animate
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            AAPLSlideSceneGraph.scenegraphDiagramGoTo(step: 5)
            _sceneKitDiagramNode?.opacity = 1.0
        }
        SCNTransaction.commit()
    }
}
