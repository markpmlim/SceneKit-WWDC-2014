/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Presents the Xcode SceneKit editor.
*/

import SceneKit

// slide #52
class AAPLSlideTechniques: APPLSlide {
    var _plistGroup: SCNNode?
    var _pass3: SCNNode?
    var _pass2: SCNNode?
    var _pass1: SCNNode?

    enum TechniqueSteps: UInt {
        case intro
        case pass1
        case passes3
        case passes3Connected
        case files
        case filesPlist
        case code
        case sample
        case count
    }

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return TechniqueSteps.count.rawValue
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
    switch (stepIndex) {
        case TechniqueSteps.intro.rawValue:
            break
        case TechniqueSteps.code.rawValue:
            self.textManager.flipOutText(ofTextType: .bullet)
            _plistGroup?.removeFromParentNode()

            self.textManager.addEmptyLine()
            _ = self.textManager.add(code:
                    "// Load a technique\nSCNTechnique *technique = [SCNTechnique #techniqueWithDictionary#:aDictionary];\n\n" +
                    "// Chain techniques\ntechnique = [SCNTechnique #techniqueBySequencingTechniques#:@[t1, t2 ...];\n\n" +
                    "// Set a technique\naSCNView.#technique# = technique;")
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .code)
        case TechniqueSteps.files.rawValue:
            do {
                _pass2?.removeFromParentNode()
                
                self.textManager.flipOutText(ofTextType: .bullet)
                _ = self.textManager.add(bullet: "Load from Plist",
                                         at: 0)
                self.textManager.flipInText(ofTextType: .code)

                _plistGroup = SCNNode()
                self.contentNode.addChildNode(_plistGroup!)

                //add plist icon
                var node = SCNNode.asc_planeNode(withImageNamed: "plist.png",
                                                 size: 8,
                                                 isLit: true)
                node.position = SCNVector3Make(0, 3.7, 10)
                _plistGroup?.addChildNode(node)

                //add plist icon
                node = SCNNode.asc_planeNode(withImageNamed: "vsh.png",
                                             size: 3,
                                             isLit: true)
                for i in 0..<5 {
                    node = node.clone()
                    node.position = SCNVector3Make(6, 1.4, CGFloat(10 - i))
                    _plistGroup?.addChildNode(node)
                }

                node = SCNNode.asc_planeNode(withImageNamed: "fsh.png",
                                             size: 3,
                                             isLit: true)
                for i in 0..<5 {
                    node = node.clone()
                    node.position = SCNVector3Make(9, 1.4, CGFloat(10 - i))
                    _plistGroup?.addChildNode(node)
                }
            }
        case TechniqueSteps.filesPlist.rawValue:
            do {
                //add plist icon
                let node = SCNNode.asc_planeNode(withImageNamed: "technique.png",
                                                 size: 9,
                                                 isLit: true)
                node.position = SCNVector3Make(0, 3.5, 10.1)
                node.opacity = 0.0
                _plistGroup?.addChildNode(node)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                node.position = SCNVector3Make(0, 3.5, 11)
                node.opacity = 1.0
                SCNTransaction.commit()
            }
        case TechniqueSteps.pass1.rawValue:
            do {
                self.textManager.flipOutText(ofTextType: .bullet)

                let node = SCNNode.asc_planeNode(withImageNamed: "pass1.png",
                                                 size: 15,
                                                 isLit: true)
                node.position = SCNVector3Make(0, 3.5, 10.1)
                node.opacity = 0.0
                self.contentNode.addChildNode(node)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                node.position = SCNVector3Make(0, 3.5, 11)
                node.opacity = 1.0
                SCNTransaction.commit()
                _pass1 = node
            }
        case TechniqueSteps.passes3.rawValue:
            do {
                _pass1?.removeFromParentNode()
                _pass2 = SCNNode()
                _pass2?.opacity = 0.0
                _pass2?.position = SCNVector3Make(0, 3.5, 6)

                var node = SCNNode.asc_planeNode(withImageNamed: "pass2.png",
                                                 size: 8,
                                                 isLit: true)
                node.position = SCNVector3Make(-8, 0, 0)
                _pass2?.addChildNode(node)

                node = SCNNode.asc_planeNode(withImageNamed: "pass3.png",
                                             size: 8,
                                             isLit: true)
                node.position = SCNVector3Make(0, 0, 0)
                _pass2?.addChildNode(node)

                node = SCNNode.asc_planeNode(withImageNamed: "pass4.png",
                                             size: 8,
                                             isLit: true)
                node.position = SCNVector3Make(8, 0, 0)
                _pass2?.addChildNode(node)

                self.contentNode.addChildNode(_pass2!)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                _pass2?.position = SCNVector3Make(0, 3.5, 9)
                _pass2?.opacity = 1.0
                SCNTransaction.commit()
            }
        case TechniqueSteps.passes3Connected.rawValue:
            do {
                self.textManager.addEmptyLine()
                _ = self.textManager.add(bullet: "Connect pass inputs/outputs",
                                         at: 0)


                let node = SCNNode.asc_planeNode(withImageNamed: "link.png",
                                                 size:8.75,
                                                 isLit: true)
                node.position = SCNVector3Make(0.01, -2, 0)
                node.opacity = 0
                _pass2?.addChildNode(node)


                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                var n = _pass2?.childNodes[0]
                n?.position = SCNVector3Make(-7.5, -0.015, 0)

                n = _pass2?.childNodes[2];
                n?.position = SCNVector3Make(7.5, 0.02, 0)

                node.opacity = 1

                SCNTransaction.commit()
            }
        case TechniqueSteps.sample.rawValue:
            do {
                self.textManager.flipOutText(ofTextType: .code)
                self.textManager.flipOutText(ofTextType: .subtitle)
                _ = self.textManager.set(subtitle: "Example—simple depth of field")
                self.textManager.flipInText(ofTextType: .code)

                _pass3 = SCNNode()

                let node = SCNNode.asc_planeNode(withImageNamed: "pass5.png",
                                                 size: 15,
                                                 isLit: true)
                node.position = SCNVector3Make(-3, 5, 10.1)
                node.opacity = 0.0;
                _pass3?.addChildNode(node)

                let t0 = SCNNode.asc_planeNode(withImageNamed: "technique0.png",
                                               size: 4,
                                               isLit: false)
                t0.position = SCNVector3Make(-8.5, 1.5, 10.1)
                t0.opacity = 0.0;
                _pass3?.addChildNode(t0)

                let t1 = SCNNode.asc_planeNode(withImageNamed: "technique1.png",
                                               size: 4,
                                               isLit: false)
                t1.position = SCNVector3Make(-3.6, 1.5, 10.1)
                t1.opacity = 0.0;
                _pass3?.addChildNode(t1)

                let t2 = SCNNode.asc_planeNode(withImageNamed: "technique2.png",
                                               size: 4,
                                               isLit: false)
                t2.position = SCNVector3Make(1.4, 1.5, 10.1)
                t2.opacity = 0.0;
                _pass3?.addChildNode(t2)

                let t3 = SCNNode.asc_planeNode(withImageNamed: "technique3.png",
                                               size: 8,
                                               isLit: false)
                t3.position = SCNVector3Make(8, 5, 10.1)
                t3.opacity = 0.0;
                _pass3?.addChildNode(t3)

                self.contentNode.addChildNode(_pass3!)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.75
                node.opacity = 1.0
                t0.opacity = 1.0
                t1.opacity = 1.0
                t2.opacity = 1.0
                t3.opacity = 1.0
                SCNTransaction.commit()
            }
        default:
            break
        }
    }


    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and add some text
        _ = self.textManager.set(title: "Multi-Pass Effects")
        _ = self.textManager.set(subtitle: "SCNTechnique")

        _ = self.textManager.add(bullet: "Multi-pass effects",
                                 at: 0)
        _ = self.textManager.add(bullet: "Post processing",
                                 at: 0)
        _ = self.textManager.add(bullet: "Chain passes",
                                 at: 0)
        _ = self.textManager.add(bullet: "Set and animate shader uniforms in Objective-C",
                                 at: 0)
    }
}
