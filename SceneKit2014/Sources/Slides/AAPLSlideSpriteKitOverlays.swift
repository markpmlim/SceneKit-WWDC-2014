/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to use SpriteKit overlays with SceneKit.
*/

import SceneKit

// slide #44
class AAPLSlideSpriteKitOverlays: APPLSlide {

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 2
    }
    

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch(stepIndex) {
        case 0:
            break
        case 1:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.addEmptyLine()
            _ = self.textManager.add(bullet: "Portability",
                                     at: 0)
            _ = self.textManager.add(bullet: "Performance",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
        default:
            break
        }
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "SpriteKit Overlays")

        _ = self.textManager.add(bullet: "Game score, gauges, time, menus...",
                                 at: 0)
        _ = self.textManager.add(bullet: "Event handling",
                                 at: 0)
        let node = self.textManager.add(code: "scnView.#overlaySKScene# = aSKScene;")
        node.position = SCNVector3Make(9, 0.7, 0)

        let gameLoop = SCNNode.asc_planeNode(withImageNamed: "overlays",
                                             size: 10,
                                             isLit: false)
        gameLoop.position = SCNVector3Make(0, 2.9, 13)
        self.groundNode.addChildNode(gameLoop)
    }
}
