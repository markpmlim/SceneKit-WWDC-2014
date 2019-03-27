/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:

Introduces the constraints API and shows severals examples.

*/

import SceneKit

// slide #32
class AAPLSlideConstraints: APPLSlide {
    var _ballNode: SCNNode?


    required init() {
        super.init()
    }
    
    override var numberOfSteps: UInt {
        return 8
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            // Set the slide's title and subtitle and add some text
            _ = self.textManager.set(title: "Constraints")
            _ = self.textManager.set(subtitle: "SCNConstraint")
            
            _ = self.textManager.add(bullet: "Applied sequentially at render time",
                                     at: 0)
            _ = self.textManager.add(bullet: "Only affect presentation values",
                                     at: 0)

            _ = self.textManager.add(code: "aNode.#constraints# = @[aConstraint, anotherConstraint, ...];")

            // Tweak the near clipping plane of the spot light to get a precise shadow map
            presentationViewController.spotLight?.light?.zNear = 10
        case 1:
            do {
                // Remove previous text
                self.textManager.flipOutText(ofTextType: .subtitle)
                self.textManager.flipOutText(ofTextType: .bullet)
                self.textManager.flipOutText(ofTextType: .code)
                // Add new text
                _ = self.textManager.set(subtitle: "SCNTransformConstraint")
                _ = self.textManager.add(bullet: "Custom constraint on a node's transform",
                                     at: 0)
                _ = self.textManager.add(code: "aConstraint = [SCNTransformConstraint #transformConstraintInWorldSpace:#YES \n" +
                "                                                            #withBlock:# \n" +
                "               ^SCNMatrix4(SCNNode *node, SCNMatrix4 transform) { \n" +
                "                   transform.m43 = 0.0; \n" +
                "                   return transform; \n" +
                "               }];")
                
                self.textManager.flipInText(ofTextType: .subtitle)
                self.textManager.flipInText(ofTextType: .bullet)
                self.textManager.flipInText(ofTextType: .code)
            }
        case 2:
            do {
                // Remove previous text
                self.textManager.flipOutText(ofTextType: .subtitle)
                self.textManager.flipOutText(ofTextType: .bullet)
                self.textManager.flipOutText(ofTextType: .code)
                
                // Add new text
                _ = self.textManager.set(subtitle: "SCNLookAtConstraint")
                _ = self.textManager.add(bullet: "Makes a node to look at another node",
                                     at: 0)
                _ = self.textManager.add(code: "nodeA.constraints = @[SCNLookAtConstraint #lookAtConstraintWithTarget#:nodeB];")
                
                _ = self.textManager.flipInText(ofTextType: .subtitle)
                _ = self.textManager.flipInText(ofTextType: .bullet)
                _ = self.textManager.flipInText(ofTextType: .code)
            }
        case 3:
            do {
                // Setup the scene
                self.setupLookAtScene()
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    // Dim the text and move back a little bit
                    self.textManager.textNode.opacity = 0.5;
                    presentationViewController.cameraHandle?.position = (presentationViewController.cameraNode?.convertPosition(SCNVector3Make(0, 0, 5.0),
                                                                                                                                to: presentationViewController.cameraHandle?.parent))!
                }
                SCNTransaction.commit()
            }
        case 4:
            do {
                // Add constraints to the arrows
                let container = self.contentNode.childNode(withName: "arrowContainer",
                                                           recursively: true)

                // "Look at" constraint
                let constraint = SCNLookAtConstraint(target: _ballNode!)
                
                var i = 0
                for arrow in (container?.childNodes)! {
                    let delayInSeconds = 0.1 * Double(i); // desynchronize the different animations
                    i += 1
                    let popTime = DispatchTime.now().rawValue + (UInt64(delayInSeconds) * NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 1.0
                        do {
                            // Animate to the result of applying the constraint
                            arrow.childNodes[0].rotation = SCNVector4Make(0, 1, 0,
                                                                          CGFloat.pi/2)
                            arrow.constraints = [constraint]
                        }
                        SCNTransaction.commit()
                    }
                }
            }
        case 5:
            do {
                // Create a keyframe animation to move the ball
                var animation = CAKeyframeAnimation(keyPath: "position")
                //var times: [NSNumber] = [0.0, 1.0/8.0, 2.0/8.0, 3.0/8.0, 4.0/8.0, 5.0/8.0, 6.0/8.0, 7.0/8.0, 1.0]
                animation.keyTimes = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
                animation.values = [
                    NSValue(scnVector3: SCNVector3Make(0, 0.0, 0)),
                    NSValue(scnVector3: SCNVector3Make(20.0, 0.0, 20.0)),
                    NSValue(scnVector3: SCNVector3Make(40.0, 0.0, 0)),
                    NSValue(scnVector3: SCNVector3Make(20.0, 0.0, -20.0)),
                    NSValue(scnVector3: SCNVector3Make(0, 0.0, 0)),
                    NSValue(scnVector3: SCNVector3Make(-20.0, 0.0, 20.0)),
                    NSValue(scnVector3: SCNVector3Make(-40.0, 0.0, 0)),
                    NSValue(scnVector3: SCNVector3Make(-20.0, 0.0, -20.0)),
                    NSValue(scnVector3: SCNVector3Make(0, 0.0, 0))
                ]
                animation.calculationMode = kCAAnimationCubicPaced; // smooth the movement between keyframes
                animation.repeatCount = Float.greatestFiniteMagnitude;
                animation.duration = 10.0;
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                _ballNode?.addAnimation(animation,
                                        forKey: nil)

                // Rotate the ball to give the illusion of a rolling ball
                // We need two animations to do that:
                // - one rotation to orient the ball in the right direction
                // - one rotation to spin the ball
                animation = CAKeyframeAnimation(keyPath: "rotation")
                //animation.keyTimes = [0.0, (0.7/8.0), (1/8.0), (2/8.0), (3/8.0), (3.3/8.0), (4.7/8.0), (5/8.0),  (6/8.0), (7/8.0), (7.3/8.0), 1.0]
                animation.keyTimes = [0.0, 0.0875, 0.125, 0.25, 0.375, 0.4125, 0.5875, 0.625,  0.75, 0.875, 0.9125, 1.0]
                animation.values = [
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi/4)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi/4)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi/2)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi + CGFloat.pi/2)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi * 2 - CGFloat.pi/4)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi * 2 - CGFloat.pi/4)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi * 2 - CGFloat.pi/2)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi - CGFloat.pi/2)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi/4)),
                    NSValue(scnVector4: SCNVector4Make(0, 1, 0, CGFloat.pi/4))
                ]
                animation.repeatCount = Float.greatestFiniteMagnitude
                animation.duration = 10.0
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                _ballNode?.addAnimation(animation, forKey: nil)
                
                let rotationAnimation = CABasicAnimation(keyPath: "rotation")
                rotationAnimation.duration = 1.0
                rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
                rotationAnimation.toValue = NSValue(scnVector4: SCNVector4Make(1, 0, 0,
                                                                               CGFloat.pi * 2))
                _ballNode?.childNodes[1].addAnimation(rotationAnimation, forKey: nil)
            }
        case 6:
            do {
                // Add a constraint to the camera
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    let constraint = SCNLookAtConstraint(target: _ballNode!)
                    constraint.isGimbalLockEnabled = true
                    presentationViewController.cameraNode?.constraints = [constraint]
                }
                SCNTransaction.commit()
            }
        case 7:
            do {
                // Add a constraint to the light
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 1.0
                do {
                    let cameraTarget = self.contentNode.childNode(withName: "cameraTarget",
                                                                  recursively: true)
                    let constraint = SCNLookAtConstraint(target: cameraTarget)
                    
                    presentationViewController.spotLight?.constraints = [constraint];
                }
                SCNTransaction.commit()
            }
        default:
            break
        }
    }
    
    
    // handles pre-early exit from a slide presentation
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        do {
            presentationViewController.cameraNode?.constraints = nil
            presentationViewController.spotLight?.constraints = nil
        }
        SCNTransaction.commit()
    }
    
    override func didOrderIn(with presentationViewController: AAPLPresentationViewController) {
    }

    func setupLookAtScene() {
        let intermediateNode = SCNNode()
        intermediateNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
        intermediateNode.position = SCNVector3Make(0, 0, 10)
        self.contentNode.addChildNode(intermediateNode)

        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = "Scenes.scnassets/pool/pool_8.png"
        ballMaterial.specular.contents = NSColor.white
        ballMaterial.shininess = 0.9    // shinny
        ballMaterial.reflective.contents = "color_envmap"
        ballMaterial.reflective.intensity = 0.5

        // Node hierarchy for the ball :
        //   _ballNode
        //  |__ cameraTarget      : the target for the "look at" constraint
        //  |__ ballRotationNode  : will rotate to animate the rolling ball
        //      |__ ballPivotNode : will own the geometry and will be rotated so that the "8" faces the camera at the beginning
        
        _ballNode = SCNNode()
        _ballNode?.rotation = SCNVector4Make(0, 1, 0,
                                             CGFloat.pi/4)
        intermediateNode.addChildNode(_ballNode!)

        let cameraTarget = SCNNode()
        cameraTarget.name = "cameraTarget"
        cameraTarget.position = SCNVector3Make(0, 6, 0)
        _ballNode?.addChildNode(cameraTarget)

        let ballRotationNode = SCNNode()
        ballRotationNode.position = SCNVector3Make(0, 4, 0)
        _ballNode?.addChildNode(ballRotationNode)

        let ballPivotNode = SCNNode()
        ballPivotNode.geometry = SCNSphere(radius: 4.0)
        ballPivotNode.geometry?.firstMaterial = ballMaterial
        ballPivotNode.rotation = SCNVector4Make(0, 1, 0,
                                                CGFloat.pi/2)
        ballRotationNode.addChildNode(ballPivotNode)

        let arrowMaterial = SCNMaterial()
        arrowMaterial.diffuse.contents = NSColor.white
        arrowMaterial.reflective.contents = NSImage(named: "chrome")

        let arrowContainer = SCNNode()
        arrowContainer.name = "arrowContainer"
        intermediateNode.addChildNode(arrowContainer)

        let arrowPath = NSBezierPath.asc_arrowBezierPath(withBaseSize: NSMakeSize(6, 2),
                                                         tipSize: NSMakeSize(3, 5),
                                                         hollow: 0.5,
                                                         twoSides: false)
        // Create the arrows
        for i in 0..<11 {
            let arrowNode = SCNNode()
            arrowNode.position = SCNVector3Make(cos(CGFloat.pi * CGFloat(i) / 10.0) * 20.0,
                                                3 + 18.5 * sin(CGFloat.pi * CGFloat(i) / 10.0),
                                                0)
            
            let arrowGeometry = SCNShape(path: arrowPath,
                                         extrusionDepth: 1)
            arrowGeometry.chamferRadius = 0.2

            let arrowSubNode = SCNNode()
            arrowSubNode.geometry = arrowGeometry
            arrowSubNode.geometry?.firstMaterial = arrowMaterial
            arrowSubNode.pivot = SCNMatrix4MakeTranslation(0, 2.5, 0) // place the pivot (center of rotation) at the middle of the arrow
            arrowSubNode.rotation = SCNVector4Make(0, 0, 1,
                                                   CGFloat.pi/2)

            arrowNode.addChildNode(arrowSubNode)
            arrowContainer.addChildNode(arrowNode)
        }
    }
}
