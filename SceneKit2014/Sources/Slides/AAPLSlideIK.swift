/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Introduces the inverse kinematic API and shows an example.
*/

import SceneKit

// slide #33 - crash if renderingAPI is OpenGL and GPU is Metal-aware i.e default renderingAPI is Metal
class AAPLSlideIK: APPLSlide, SCNSceneRendererDelegate {
    var _ik: SCNIKConstraint?
    var _lookAt: SCNLookAtConstraint?
    var _attack: CAAnimation?
    var _hero: SCNNode?
    var _target: SCNNode?
    var _ikActive: Bool?

    var _animationStartTime: CFTimeInterval?
    var _animationDuration: CFTimeInterval?

    required init() {
        _ikActive = false
        super.init()
    }

    override var numberOfSteps: UInt {
        return 9
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Set the slide's title and subtitle and add some text
        _ = self.textManager.set(title: "Constraints")
        _ = self.textManager.set(subtitle: "SCNIKConstraint")

        _ = self.textManager.add(bullet: "Inverse kinematics", at: 0)
        _ = self.textManager.add(bullet: "Node chain", at: 0)
        _ = self.textManager.add(bullet: "Target", at: 0)

        //load the hero - suffix dae not specified?
        _hero = self.groundNode.asc_addChildNode(named: "heroGroup",
                                                 fromSceneNamed: "Scenes.scnassets/hero/hero",
                                                 withScale: 12)
        _hero?.position = SCNVector3Make(0, 0, 5)

        //hide the sword
        let sword = _hero?.childNode(withName: "sword",
                                     recursively: true)
        sword?.isHidden = true

        let path = Bundle.main.path(forResource: "attack",
                                    ofType: "dae",
                                    inDirectory: "Scenes.scnassets/hero")

        let source = SCNSceneSource(url: URL(fileURLWithPath: path!),
                                    options: nil)

        _attack = source?.entryWithIdentifier("attackID",
                                              withClass: CAAnimation.self)
        _attack?.repeatCount = 0
        _attack?.fadeInDuration = 0.1
        _attack?.fadeOutDuration = 0.3
        _attack?.speed = 0.75

        _attack?.animationEvents = [SCNAnimationEvent(keyTime: 0.55, block: {
            (animation: CAAnimation, animatedObject: Any, playingBackward: Bool) -> Void in
            if (self._ikActive!) {
                self.destroyTarget()
            }
        })]

        _animationDuration = _attack?.duration
        
        //setup IK
        let hand = _hero?.childNode(withName: "Bip01_R_Hand",
                                    recursively: true)
        let clavicle = _hero?.childNode(withName: "Bip01_R_Clavicle",
                                        recursively: true)
        let head = _hero?.childNode(withName: "Bip01_Head",
                                    recursively: true)

        _ik = SCNIKConstraint.inverseKinematicsConstraint(chainRootNode: clavicle!)
        hand?.constraints = [_ik!]
        _ik?.influenceFactor = 0.0

        //add target
        _target = SCNNode()
        _target?.position = SCNVector3Make(-4, 7, 10)
        _target?.opacity = 0
        _target?.geometry = SCNPlane(width: 2,
                                     height: 2)
        _target?.geometry?.firstMaterial?.diffuse.contents = "target.png"
        self.groundNode.addChildNode(_target!)

        //look at
        _lookAt = SCNLookAtConstraint(target: _target)
        _lookAt?.influenceFactor = 0
        head?.constraints = [_lookAt!]

        presentationViewController.presentationView.delegate = self
    }

    // Implementation of an SCNSceneRendererDelegate protocol method
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        if _ikActive! {
            // update the influence factor of the IK constraint based on the animation progress
            var currProgress = Double((_attack?.speed)!) * (time - _animationStartTime!) / _animationDuration!

            //clamp
            currProgress = max(0, currProgress)
            currProgress = min(1, currProgress)

            if currProgress >= 1 {
                _ikActive = false
            }

            let middle = 0.5
            var f: Double

            // smoothly increate from 0% to 50% then smoothly decrease from 50% to 100%
            if currProgress > middle {
                f = (1.0-currProgress)/(1.0-middle)
            }
            else {
                f = currProgress/middle
            }

            _ik?.influenceFactor = CGFloat(f)
            _lookAt?.influenceFactor = CGFloat(1.0 - f)
        }
    }
    
    func moveTarget(_ step: UInt) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.75
        switch(step) {
        case 0:
            _ik?.targetPosition = self.groundNode.convertPosition(SCNVector3Make(-70, 2, 50),
                                                                  to: nil)
        case 1:
            _target?.position = SCNVector3Make(-1, 4, 10);
            _ik?.targetPosition = self.groundNode.convertPosition(SCNVector3Make(-30, -50, 50),
                                                                  to: nil)
        case 2:
            _target?.position = SCNVector3Make(-5, 5, 10)
            _ik?.targetPosition = self.groundNode.convertPosition(SCNVector3Make(-30, -50, 50),
                                                                  to: nil)
        default:
            break
        }
        _target?.opacity = 1
        SCNTransaction.commit()
    }

    func destroyTarget(){
        _target?.opacity = 0
        let ps = SCNParticleSystem(named: "explosion.scnp",
                                   inDirectory: nil)
        _target?.addParticleSystem(ps!)
    }

    override func present(stepIndex: UInt,
                          with presentationViewController: AAPLPresentationViewController) {
        switch (stepIndex) {
        case 0:
            break;
        case 1://punch
            _hero?.addAnimation(_attack!,
                                forKey: "attack")
            _animationStartTime = CACurrentMediaTime()
        case 2://add target
            self.moveTarget(0)
        case 3://punch
            _hero?.addAnimation(_attack!,
                                forKey: "attack")
            _animationStartTime = CACurrentMediaTime()
        case 4://punch + IK - crash
            _ikActive = true
            _lookAt?.influenceFactor = 1
            _hero?.addAnimation(_attack!,
                                forKey: "attack")
            _animationStartTime = CACurrentMediaTime()
        case 5://punch
           self.moveTarget(1)
        case 6:
            _ikActive = true
            _hero?.addAnimation(_attack!,
                                forKey: "attack")
            _animationStartTime = CACurrentMediaTime()
        case 7://punch
            self.moveTarget(2)
        case 8:
            _ikActive = true
            _hero?.addAnimation(_attack!,
                                forKey: "attack")
            _animationStartTime = CACurrentMediaTime()
        default:
            break
        }
    }
    override func willOrderOut(with presentationViewController: AAPLPresentationViewController) {
        //clear delegate
        presentationViewController.presentationView.delegate = nil
    }
}
