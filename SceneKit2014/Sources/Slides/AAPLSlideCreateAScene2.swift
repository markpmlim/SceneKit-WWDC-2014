/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Creating a Scene slide, part 2.

*/

// This class has not "Parameters" or "Info"
import SceneKit

// slide #15
class AAPLSlideCreateAScene2: APPLSlide {

    required init() {
        super.init()
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "Creating a Scene")
  
        _ = self.textManager.add(bullet: "Creating programmatically",
                             at: 0)
        _ = self.textManager.add(bullet: "Loading a scene from a file",
                                 at: 0)
        // Automatically highlight the second bullet after one second
        let delayInSeconds = 1.0
        let popTime = DispatchTime.now().rawValue + (UInt64(delayInSeconds) * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
            self.textManager.highlightBullet(at: 1)
        }
    }
}
