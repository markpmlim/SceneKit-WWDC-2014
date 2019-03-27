/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

The different ways to manipulate objects.

*/

import SceneKit

// slide #23
class AAPLSlideAnimationOutline: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Animating a Scene")
        _ = self.textManager.set(subtitle: "Outline")

        _ = self.textManager.add(bullet: "Per-frame updates", at: 0)
        _ = self.textManager.add(bullet: "Animations", at: 0)
        _ = self.textManager.add(bullet: "Actions", at: 0)
        _ = self.textManager.add(bullet: "Physics", at: 0)
        _ = self.textManager.add(bullet: "Constraints", at: 0)
        _ = self.textManager.add(bullet: "Morphing", at: 0)
        _ = self.textManager.add(bullet: "Skinning", at: 0)
    }
}
