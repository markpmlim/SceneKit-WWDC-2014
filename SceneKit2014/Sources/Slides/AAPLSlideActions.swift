/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Present actions.

*/
import SceneKit

// slide #29
class AAPLSlideActions: APPLSlide {
    var _animatedNode: SCNNode?

    required init() {
        _animatedNode = SCNNode()
        super.init()
    }

    override var numberOfSteps: UInt {
        return 5
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some code
        _ = self.textManager.set(title: "Actions")
        _ = self.textManager.set(subtitle: "SCNAction")

        _ = self.textManager.add(bullet: "Easy to sequence, group, and repeat",
                                 at: 0)
        _ = self.textManager.add(bullet: "Limited to SCNNode",
                                 at: 0)
        _ = self.textManager.add(bullet: "Same programming model as SpriteKit",
                                 at: 0)
    }

    override func present(stepIndex: UInt,
                          with: AAPLPresentationViewController) {
        // Animate by default
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0

        switch stepIndex {
        case 0:
            // Initially hide the torus
            _animatedNode?.opacity = 0.0
        case 1:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.addEmptyLine()
            _ = self.textManager.add(code:
                "// Rotate forever\n" +
                "[aNode #runAction:#\n" +
                "  [SCNAction repeatActionForever:\n" +
                "  [SCNAction rotateByX:0 y:M_PI*2 z:0 duration:5.0]]];")
            self.textManager.flipInText(ofTextType: .code)
        case 2:
            self.textManager.flipOutText(ofTextType: .bullet)
            self.textManager.flipOutText(ofTextType: .code)

            _ = self.textManager.add(bullet: "Move",
                                     at: 0)
            _ = self.textManager.add(bullet: "Rotate",
                                     at: 0)
            _ = self.textManager.add(bullet: "Scale",
                                     at: 0)
            _ = self.textManager.add(bullet: "Opacity",
                                     at: 0)
            _ = self.textManager.add(bullet: "Remove",
                                     at: 0)
            _ = self.textManager.add(bullet: "Wait",
                                     at: 0)
            _ = self.textManager.add(bullet: "Custom block",
                                 at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
        case 3:
            self.textManager.flipOutText(ofTextType: .bullet)
            _ = self.textManager.add(bullet: "Directly updates the presentation tree",
                                     at: 0)
            self.textManager.flipInText(ofTextType: .bullet)
        case 4:
            do {
                _ = self.textManager.add(bullet: "node.position ≠ node.presentationNode.position",
                                         at: 0)

                //labels
                let label1 = self.textManager.add(text: "Action",
                                                  at: 0)
                label1.position = SCNVector3Make(-15, 3, 0)
                let label2 = self.textManager.add(text: "Animation",
                                                  at: 0)
                label2.position = SCNVector3Make(-15, -2, 0)

                //animation
                let animNode = SCNNode()
                let cubeSize: CGFloat = 4.0
                animNode.position = SCNVector3Make(-5, cubeSize/2, 0)

                let cube = SCNBox(width: cubeSize,
                                  height: cubeSize,
                                  length: cubeSize,
                                  chamferRadius: 0.05 * cubeSize)

                cube.firstMaterial?.diffuse.contents = "texture.png"
                cube.firstMaterial?.diffuse.mipFilter = .nearest
                cube.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
                cube.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
                animNode.geometry = cube;
                self.contentNode.addChildNode(animNode)

                SCNTransaction.begin()
                var animPosIndicator: SCNNode? = nil

                let startEvt = SCNAnimationEvent(keyTime: 0, block: {
                    (animation, animatedObject, playingBackward) in

                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0
                    animPosIndicator?.position = SCNVector3Make(10,
                                                                (animPosIndicator?.position.y)!,
                                                                (animPosIndicator?.position.z)!);
                    SCNTransaction.commit()
                })

                let endEvt = SCNAnimationEvent(keyTime: 1, block: {
                    (animation, animatedObject, playingBackward) in

                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0
                    animPosIndicator?.position = SCNVector3Make(-5,
                                                                (animPosIndicator?.position.y)!,
                                                                (animPosIndicator?.position.z)!);

                    SCNTransaction.commit()
                })

                let anim = CABasicAnimation(keyPath: "position.x")
                anim.duration = 3
                anim.fromValue = 0.0
                anim.toValue = 15.0
                anim.isAdditive = true
                anim.autoreverses = true
                anim.animationEvents = [startEvt, endEvt]
                anim.repeatCount = MAXFLOAT
                animNode.addAnimation(anim, forKey: nil)

                //action
                let actionNode = SCNNode()
                actionNode.position = SCNVector3Make(-5, cubeSize*1.5 + 1, 0)
                actionNode.geometry = cube

                self.contentNode.addChildNode(actionNode)

                let mv = SCNAction.moveBy(x: 15, y: 0, z: 0,
                                          duration: 3)

                actionNode.runAction(SCNAction.repeatForever(SCNAction.sequence([mv, mv.reversed()])))

                //position indicator (a small red dot)
                let positionIndicator = SCNNode()
                positionIndicator.geometry = SCNCylinder(radius: 0.5,
                                                         height: 0.01)
                positionIndicator.geometry?.firstMaterial?.diffuse.contents = NSColor.red
                positionIndicator.geometry?.firstMaterial?.lightingModel = .constant
                positionIndicator.eulerAngles = SCNVector3Make(CGFloat.pi/2, 0, 0)
                positionIndicator.position = SCNVector3Make(0, 0, cubeSize*0.5)
                actionNode.addChildNode(positionIndicator)

                //anim pos indicator
                animPosIndicator = positionIndicator.clone() as SCNNode
                animPosIndicator?.position = SCNVector3Make(5, cubeSize/2, cubeSize*0.5)
                self.contentNode.addChildNode(animPosIndicator!)

                SCNTransaction.commit()
            }
        default:
            break
        }
        SCNTransaction.commit()
    }
}
