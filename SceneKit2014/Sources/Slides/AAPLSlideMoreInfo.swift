/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to get more information about SceneKit.
*/


import SceneKit

// slide #60
class AAPLSlideMoreInfo: APPLSlide {

    required init() {
        super.init()
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        _ = self.textManager.set(title: "More Information")

        _ = self.textManager.add(text: "Allan Schaffer", at:0)
        var node = self.textManager.add(text: "Graphics and Game Technologies Evangelist",
                                        at: 1)
        node.opacity = 0.56
        _ = self.textManager.add(text:"aschaffer@apple.com", at: 2)
        self.textManager.addEmptyLine()

        _ = self.textManager.add(text:"Filip Iliescu", at: 0)
        node = self.textManager.add(text:"Graphics and Game Technologies Evangelist",
                                    at: 1)
        node.opacity = 0.56
        _ = self.textManager.add(text:"filiescu@apple.com",
                                 at: 2)
        self.textManager.addEmptyLine()

        _ = self.textManager.add(text:"Documentation",
                                 at: 0)
        node = self.textManager.add(text:"SceneKit Framework Reference",
                                    at: 1)
        node.opacity = 0.56
        _ = self.textManager.add(text:"http://developer.apple.com",
                                 at: 2)
        self.textManager.addEmptyLine()

        _ = self.textManager.add(text:"Apple Developer Forums",
                                 at: 0)
        _ = self.textManager.add(text:"http://devforums.apple.com",
                                 at: 2)
    }
}
