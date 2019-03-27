//
/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to use SCNView within Interface Builder.
*/

import SceneKit

// slide #11
class AAPLSlideInterfaceBuilder: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Add some text
        _ = self.textManager.set(title: "Displaying the Scene")
        _ = self.textManager.set(subtitle: "Game template")
        
        _ = self.textManager.add(bullet: "Start with the Xcode game template",
                                 at: 0)
        _ = self.textManager.add(bullet: "Or drag an SCNView from the library",
                                 at: 0)

        // And an image
        var imageNode = SCNNode.asc_planeNode(withImageNamed: "Interface Builder",
                                              size: 8.3,
                                              isLit: false)
        imageNode.position = SCNVector3Make(-4.0, 3.2, 11.0)
        self.contentNode.addChildNode(imageNode)

        imageNode = SCNNode.asc_planeNode(withImageNamed: "game_big",
                                          size: 7,
                                          isLit: false)
        imageNode.position = SCNVector3Make(5.0, 3.5, 11.0)
        imageNode.geometry?.firstMaterial?.diffuse.magnificationFilter = .nearest
        self.contentNode.addChildNode(imageNode)
    }
}
