/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Shows an example of how Core Image filters can be used to achieve screen-space effects.

*/

import SceneKit

// slide #51
class AAPLSlideCoreImage: APPLSlide {
    var _viewportSize: CGSize?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 1
    }
    
    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _viewportSize = presentationViewController.presentationView.convertToBacking(presentationViewController.presentationView.frame.size)
    }
    
    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
        var banana = self.contentNode.asc_addChildNode(named: "banana",
                                                       fromSceneNamed: "Scenes.scnassets/banana/banana",
                                                       withScale: 5)

        banana.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0,
                                                                    y: (CGFloat.pi*2),
                                                                    z: 0,
                                                                    duration: 1.5)))
        banana.position = SCNVector3Make(2.5, 5, 10)
        var filter = CIFilter(name: "CIGaussianBlur")
        filter?.setDefaults()
        filter?.setValue(10,
                         forKey: kCIInputRadiusKey)
        banana.filters = [filter!]

        banana = banana.copy() as! SCNNode
        self.contentNode.addChildNode(banana)
        banana.position = SCNVector3Make(6, 5, 10)
        filter = CIFilter(name: "CIPixellate")
        filter?.setDefaults()
        banana.filters = [filter!]


        banana = banana.copy() as! SCNNode
        self.contentNode.addChildNode(banana)
        banana.position = SCNVector3Make(9.5, 5, 10);
        filter = CIFilter(name: "CIEdgeWork")
        filter?.setDefaults()
        banana.filters = [filter!]
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            // Set the slide's title and subtitle and add some text
            _ = self.textManager.set(title: "Core Image")
            _ = self.textManager.set(subtitle: "CI Filters")

            _ = self.textManager.add(bullet: "Screen-space effects",
                                     at :0)
            _ = self.textManager.add(bullet: "Applies to a node hierarchy",
                                     at :0)
            _ = self.textManager.add(bullet: "Filter parameters are animatable",
                                     at :0)
            _ = self.textManager.add(code: "aNode.#filters# = @[filter1, filter2];")
        default:
            break
        }
    }

}
