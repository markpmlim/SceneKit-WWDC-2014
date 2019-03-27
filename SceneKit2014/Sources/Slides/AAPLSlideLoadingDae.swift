/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Presents what dae documents are.
*/


import SceneKit

// slide #16
class AAPLSlideLoadingDae: APPLSlide {
    var _nodesToDim: [SCNNode]?
    var _daeIcon: SCNNode?
    var _abcIcon: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 2
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Add some text
        _ = self.textManager.set(title: "Loading a 3D Scene")
        _ = self.textManager.set(subtitle: "Collada documents")

        _nodesToDim = [SCNNode]()
        _ = self.textManager.add(bullet: "Geometries", at: 0)
        _ = self.textManager.add(bullet: "Animations", at: 0)
        _nodesToDim?.append(self.textManager.add(bullet: "Textures",
                                                 at: 0))
        _nodesToDim?.append(self.textManager.add(bullet: "Lighting",
                                                 at: 0))
        _nodesToDim?.append(self.textManager.add(bullet: "Cameras",
                                                 at: 0))
        _nodesToDim?.append(self.textManager.add(bullet: "Skinning",
                                                 at: 0))
        _nodesToDim?.append(self.textManager.add(bullet: "Morphing",
                                                 at: 0))

        // And an image resting on the ground
        _daeIcon = SCNNode.asc_planeNode(withImageNamed: "dae file icon",
                                         size: 10,
                                         isLit: false)
        _daeIcon?.position = SCNVector3Make(6, 4.5, 1)

        self.groundNode.addChildNode(_daeIcon!)

        _abcIcon = SCNNode.asc_planeNode(withImageNamed: "abc file icon",
                                         size: 10,
                                         isLit: false)
        _abcIcon?.position = SCNVector3Make(6, 4.5, 30)
        self.groundNode.addChildNode(_abcIcon!)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        if (stepIndex == 1) {
            presentationViewController.setShowsNewInSceneKitBadge(showsBadge: true)
            
            self.textManager.flipOutText(ofTextType: .subtitle)

            _ = self.textManager.set(subtitle: "Alembic documents")
            
            self.textManager.flipInText(ofTextType: .subtitle)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            for node in _nodesToDim! {
                node.opacity = 0.5
            }
            _daeIcon?.position = SCNVector3Make(6, 4.5, -30)
            _abcIcon?.position = SCNVector3Make(6, 4.5, 1)
            SCNTransaction.commit()
        }
    }
}
