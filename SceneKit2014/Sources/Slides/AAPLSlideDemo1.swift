/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

 None

*/

import SceneKit

// slide #31
class AAPLSlideDemo1: APPLSlide {
    var _chapterNode: SCNNode?

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _chapterNode = self.textManager.set(chapterTitle: "Car Toy Demo")
    }

    // handles pre-early exit from a slide presentation
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        _chapterNode?.position = SCNVector3Make(_chapterNode!.position.x-30,
                                                _chapterNode!.position.y,
                                                _chapterNode!.position.z);
        SCNTransaction.commit()
    }
}
