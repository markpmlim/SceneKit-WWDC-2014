/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Chapter 7 slide

*/
import SceneKit

// slide #53
class AAPLSlideChapter7: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(chapterTitle: "Performance")
    }
}
