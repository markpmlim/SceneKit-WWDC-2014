/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how you can animate objects.
*/

import SceneKit

// slide #24
class AAPLSlideManipulation: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Per-Frame Updates")
        _ = self.textManager.set(subtitle: "Game loop")
        
        let gameLoop = SCNNode.asc_planeNode(withImageNamed: "gameLoop",
                                             size: 20,
                                             isLit: false)
        gameLoop.position = SCNVector3Make(0, 5.5, 10)
        self.groundNode.addChildNode(gameLoop)
    }
}
