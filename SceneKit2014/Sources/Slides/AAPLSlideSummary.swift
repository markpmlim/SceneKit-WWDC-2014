/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Give a summary of SceneKit's features.
*/

import SceneKit

// slide #59
class AAPLSlideSummary: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title:  "Summary")
        _ = self.textManager.add(bullet: "SceneKit available on iOS",
                                 at: 0)
        _ = self.textManager.add(bullet: "Casual game ready",
                                 at: 0)
        _ = self.textManager.add(bullet: "Full featured rendering",
                                 at: 0)
        _ = self.textManager.add(bullet: "Extendable",
                                 at: 0)
    }
}
