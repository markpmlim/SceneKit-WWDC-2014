/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Creating a Scene slide, part 1.

*/

import SceneKit

// slide #13
class AAPLSlideCreateAScene: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Creating a Scene")

        _ = self.textManager.add(bullet: "Creating programmatically",
                                 at: 0)
        _ = self.textManager.add(bullet: "Loading a scene from a file",
                                 at: 0)
    }
}
