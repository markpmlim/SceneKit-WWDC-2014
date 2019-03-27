/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how you can animate objects.
*/

import SceneKit

// slide #25
class AAPLSlideManipulation4: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Scene Manipulation")
        _ = self.textManager.set(subtitle: "Animations")

        _ = self.textManager.add(bullet: "Properties are animatable",
                                 at: 0)
        _ = self.textManager.add(bullet: "Implicit and explicit animations",
                                 at: 0)
        _ = self.textManager.add(bullet: "Same programming model as Core Animation",
                                 at: 0)
    }
}
