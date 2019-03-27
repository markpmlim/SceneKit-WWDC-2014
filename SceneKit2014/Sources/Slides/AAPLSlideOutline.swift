/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Presents the outline of the presentation.
*/


import SceneKit

// slide #4
class AAPLSlideOutline: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Outline")

        _ = self.textManager.add(bullet: "Scene graph overview",
                                 at: 0)

        _ = self.textManager.add(bullet: "Getting started",
                                 at: 0)
        _ = self.textManager.add(bullet: "Animating",
                                 at: 0)
        _ = self.textManager.add(bullet: "Rendering",
                                 at: 0)
        _ = self.textManager.add(bullet: "Effects",
                                 at: 0)
        _ = self.textManager.add(bullet: "Performances",
                                 at: 0)
    }
}
