/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Explains how to integrate Javascript and SceneKit API.
*/

import SceneKit

// slide #36
class AAPLSlideJS: APPLSlide {

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 3
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some code
        _ = self.textManager.set(title: "Scriptability")

        _ = self.textManager.add(bullet: "Javascript bridge",
                                 at: 0)
        _ = self.textManager.add(code:"// setup a JSContext for SceneKit\n#SCNExportJavaScriptModule#(aJSContext);\n\n" +
            "// reference a SceneKit object from JS\naJSContext.#globalObject#[@\"aNode\"] = aNode;\n\n" +
            "// execute a script\n[aJSContext #evaluateScript#:@\"aNode.scale = {x:2, y:2, z:2};\";")
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            break
        case 1:
            self.textManager.flipOutText(ofTextType: .code)
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.addEmptyLine()
            _ = _ = self.textManager.add(bullet: "Javascript code example",
                                 at: 0)
            _ = self.textManager.add(code: "\n#//allocate a node#\n" +
                "var aNode = SCNNode.node();\n\n" +
                "#//change opacity#\n" +
                "aNode.opacity = 0.5;\n\n" +
                "#//remove from parent#\n" +
                "aNode.removeFromParentNode();\n\n" +
                "#//animate implicitly#\n" +
                "SCNTransaction.begin();\n" +
                "SCNTransaction.setAnimationDuration(1.0);\n" +
                "aNode.scale = {x:2, y:2, z:2};\n" +
                "SCNTransaction.commit();")
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)
        case 2:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.flipOutText(ofTextType: .code)
            _ = self.textManager.add(bullet: "Tools",
                                     at: 0)
            _ = self.textManager.add(bullet: "Debugging",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
        default:
            break
        }
    }
}
