/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Shows how to set a scene to a renderer.
*/

import SceneKit

// slide #21
class AAPLSlideRenderAScene: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Displaying the Scene")

        _ = self.textManager.add(bullet: "Assign the scene to the renderer",
                                 at: 0)
        _ = self.textManager.add(bullet: "Modifications of the scene graph are automatically reflected",
                                 at: 0)

        _ = self.textManager.add(code: "// Assign the scene \n" +
                    "aSCNView.#scene# = aScene;")
    }
}
