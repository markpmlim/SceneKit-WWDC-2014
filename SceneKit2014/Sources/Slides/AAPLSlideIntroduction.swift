/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Introduction slide.
*/

import SceneKit

// slide #1
class AAPLSlideIntroduction: APPLSlide {
    var boxes = [SCNNode]()
    var icon1: SCNNode?
    var icon2: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 3
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text.
        _ = self.textManager.set(title: "SceneKit")
        _ = self.textManager.set(subtitle: "Introduction")
        _ = self.textManager.add(bullet: "High level API for 3D integration",
                                 at: 0)
        _ = self.textManager.add(bullet: "Data visualization", at: 1)
        _ = self.textManager.add(bullet: "User interface", at: 1)
        _ = self.textManager.add(bullet: "Casual games", at: 1)

        // Build the Cocoa graphics stack
        let redColor    = NSColor(deviceRed:168 / 255.0, green:21 / 255.0, blue:1 / 255.0, alpha:1)
        let grayColor   = NSColor.gray
        let greenColor  = NSColor(deviceRed:105 / 255.0, green:145.0 / 255.0, blue:14.0 / 255.0, alpha:1);
        let orangeColor = NSColor.orange
        let purpleColor = NSColor(deviceRed:152 / 255.0, green:57 / 255.0, blue:189 / 255.0, alpha:1)

        self.addBox(with: "Cocoa",
                    frame: NSMakeRect(0, 0, 500, 70),
                    level: 3,
                    color: grayColor)

        self.addBox(with: "Core Image",
                    frame: NSMakeRect(0, 0, 100, 70),
                    level: 2,
                    color: greenColor)

        self.addBox(with: "Core Animation",
                    frame: NSMakeRect(390, 0, 110, 70),
                    level: 2,
                    color: greenColor)

        self.addBox(with: "SpriteKit",
                    frame: NSMakeRect(250, 0, 135, 70),
                    level: 2,
                    color: greenColor)

        self.addBox(with: "SceneKit",
                    frame: NSMakeRect(105, 0, 140, 70),
                    level: 2,
                    color: orangeColor)

        self.addBox(with: "OpenGL/OpenGL ES",
                    frame: NSMakeRect(0, 0, 500, 70),
                    level: 1,
                    color: purpleColor)
        
        self.addBox(with: "Graphics Hardware",
                    frame: NSMakeRect(0, 0, 500, 70),
                    level: 0,
                    color: redColor)

    }

    func addBox(with title: String,
                frame: NSRect,
                level: UInt,
                color: NSColor) {

        let node = SCNNode.asc_boxNode(title: title,
                                       frame: frame,
                                       color: color,
                                       cornerRadius: 2.0,
                                       centered: true)
        node.pivot = SCNMatrix4MakeTranslation(0, frame.size.height / 2, 0)
        node.scale = SCNVector3Make(0.02, 0, 0.02)
        node.position = SCNVector3Make(-5,
                                       CGFloat((0.02 * frame.size.height / 2)) + CGFloat((1.5 * Double(level))),
                                       10.0)
        node.rotation = SCNVector4Make(1, 0, 0,
                                       CGFloat.pi/2)
        node.opacity = 0.0
        self.contentNode.addChildNode(node)
        boxes.append(node)

    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {

        var delay: Float = 0
        switch stepIndex {
        case 0:
            break
        case 1:
            self.textManager.flipOutText(ofTextType: .bullet)
            _ = self.textManager.add(bullet:"Available on OS X 10.8+ and iOS 8.0",
                                 at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
            //show some nice icons
            icon1 = SCNNode.asc_planeNode(withImageNamed: "Badge_X.png",
                                          size:7.5,
                                          isLit: false)
            icon1?.position = SCNVector3Make(-20, 3.5, 5)
            self.groundNode.addChildNode(icon1!)

            icon2 = SCNNode.asc_planeNode(withImageNamed: "Badge_iOS.png",
                                          size:7,
                                          isLit: false)
            icon2?.position = SCNVector3Make(20, 3.5, 5);
            self.groundNode.addChildNode(icon2!)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.75
            icon1?.position = SCNVector3Make(-6, 3.5, 5)
            icon2?.position = SCNVector3Make(6, 3.5, 5)
            SCNTransaction.commit()
        case 2:
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.75
            icon1?.position = SCNVector3Make(-6, 3.5, -5)
            icon2?.position = SCNVector3Make(6, 3.5, -5)
            icon1?.opacity = 0.0
            icon2?.opacity = 0.0;
            SCNTransaction.commit()

            // only called by the first node!
            for node in boxes {
                let popTime = DispatchTime.now().rawValue + (UInt64(delay) * NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5

                    node.rotation = SCNVector4Make(1, 0, 0, 0)
                    node.scale = SCNVector3Make(0.02, 0.02, 0.02)
                    node.opacity = 1.0
                    SCNTransaction.commit()
                }
                delay += 0.05
            }


            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.flipOutText(ofTextType: .subtitle)

            _ = self.textManager.set(subtitle: "Graphic Frameworks")
            
            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .subtitle)

        default:
            break
        }
    }
}
