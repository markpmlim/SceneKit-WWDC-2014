/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Created by mark lim pak mun on 01/07/2017.

Abstract:
Illustates how skinning can be used to animate characters.
*/

import SceneKit

// slide #35
class AAPLSlideSkinning: APPLSlide {
    var _idleAnimationGroup: CAAnimationGroup?
    var _animationGroup1: CAAnimationGroup?
    var _animationGroup2: CAAnimationGroup?

    var _characterNode: SCNNode?
    var _skeletonNode: SCNNode?

    required init() {
        super.init()
    }

    override var numberOfSteps: UInt {
        return 7
    }

    override func setupSlide(with presentationViewController: AAPLPresentationViewController) {
        // Using a scene source allows us to retrieve the animations using their identifier
        let sceneURL = Bundle.main.url(forResource: "skinning",
                                       withExtension: "dae",
                                       subdirectory: "Scenes.scnassets/skinning")
        let sceneSource = SCNSceneSource(url: sceneURL!,
                                         options:nil)

        // Place the character in the scene
        var scene: SCNScene?
        do {
            scene = sceneSource?.scene(options: nil)
        }

        _characterNode = (scene?.rootNode.childNode(withName: "avatar_attach",
                                                    recursively: true))!
        _characterNode?.scale = SCNVector3Make(0.004, 0.004, 0.004)
        _characterNode?.position = SCNVector3Make(5, 0, 12)
        _characterNode?.rotation = SCNVector4Make(0, 1, 0, -CGFloat.pi / 8)
        _characterNode?.isHidden = true
        self.groundNode.addChildNode(_characterNode!)

        _skeletonNode = _characterNode?.childNode(withName: "skeleton",
                                                  recursively: true)!
        // Prepare the other resources
        self.loadGhostEffect()
        self.extractAnimations(from: sceneSource!)
    }

    override func present(stepIndex: UInt,
                 with presentationViewController: AAPLPresentationViewController) {

        SCNTransaction.begin()

        switch (stepIndex) {
        case 0:
            do {
                    // Set the slide's title and subtitle and add some text
                    _ = self.textManager.set(title: "Skinning")

                    _ = self.textManager.add(bullet: "Animate characters", at: 0)
                    _ = self.textManager.add(bullet: "Deform geometries with a skeleton", at: 0)
                    _ = self.textManager.add(bullet: "Joints and bones", at: 0)

                    // Animate the character
                    _characterNode?.addAnimation(_idleAnimationGroup!,
                                                 forKey: "idleAnimation")

                    // The character is hidden. Wait a little longer before showing it
                    // otherwise it may slow down the transition from the previous slide
                    let delayInSeconds = 1.5
                    let popTime = DispatchTime.now().rawValue + (UInt64(delayInSeconds) * NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: popTime)) {
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0
                        do  {
                            self._characterNode?.isHidden = false
                            self._characterNode?.opacity = 0
                        }
                        SCNTransaction.commit()
                        
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 1.5
                        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                        do {
                            self._characterNode?.opacity = 1
                        }
                        SCNTransaction.commit()

                    }
                }
        case 1:
            SCNTransaction.animationDuration = 1.5
            self.setShowsBones(true)
        case 2:
            _characterNode?.addAnimation(_animationGroup1!,
                                         forKey: "animation")
        case 3:
            SCNTransaction.animationDuration = 1.5
            self.setShowsBones(false)
        case 4:
            _characterNode?.addAnimation(_animationGroup1!,
                                         forKey: "animation")
        case 5:
            // Simulate a new slide by changing all the text and animate these changes
            self.textManager.flipOutText(ofTextType: .bullet)

            _ = self.textManager.set(subtitle: "SCNSkinner")

            _ = self.textManager.add(bullet: "Can be loaded from DAEs", at: 0)
            _ = self.textManager.add(bullet: "Can be created programmatically", at: 0)

            self.textManager.flipInText(ofTextType: .bullet)
            self.textManager.flipInText(ofTextType: .subtitle)
        case 6:
            _characterNode?.addAnimation(_animationGroup2!,
                                         forKey: "animation")
        default:
            break
        }
        SCNTransaction.commit()
    }

    func extractAnimations(from sceneSource: SCNSceneSource) {
        // In this scene objects are animated separately using long animations
        // playing 3 successive animations. We will group these long animations
        // and then split the group in 3 different animation groups.
        // We could also have used three DAEs (one per animation).

        let animationIDs = sceneSource.identifiersOfEntries(withClass: CAAnimation.self)

        let animationCount = animationIDs.count
        var longAnimations = [CAAnimation]()

        var maxDuration: CFTimeInterval = 0

        for index in 0..<animationCount {
            let animation = sceneSource.entryWithIdentifier(animationIDs[index],
                                                            withClass: CAAnimation.self)
            if (animation != nil) {
                maxDuration = max(maxDuration, (animation?.duration)!)
                longAnimations.append(animation!)
            }
        }

        let longAnimationsGroup = CAAnimationGroup()
        longAnimationsGroup.animations = longAnimations
        longAnimationsGroup.duration = maxDuration

        let idleAnimationGroup = longAnimationsGroup.copy() as! CAAnimationGroup
        idleAnimationGroup.timeOffset = 6.45833333333333
        _idleAnimationGroup = CAAnimationGroup()
        _idleAnimationGroup?.animations = [idleAnimationGroup]
        _idleAnimationGroup?.duration = 24.71 - 6.45833333333333
        _idleAnimationGroup?.repeatCount = .greatestFiniteMagnitude
        _idleAnimationGroup?.autoreverses = true

        let animationGroup1 = longAnimationsGroup.copy() as! CAAnimationGroup
        _animationGroup1 = CAAnimationGroup()
        _animationGroup1?.animations = [animationGroup1]
        _animationGroup1?.duration = 1.4
        _animationGroup1?.fadeInDuration = 0.1
        _animationGroup1?.fadeOutDuration = 0.5

        let animationGroup2 = longAnimationsGroup.copy() as! CAAnimationGroup
        animationGroup2.timeOffset = 3.666666666666667
        _animationGroup2 = CAAnimationGroup()
        _animationGroup2?.animations = [animationGroup2]
        _animationGroup2?.duration = 6.416666666666667 - 3.666666666666667
        _animationGroup2?.fadeInDuration = 0.1
        _animationGroup2?.fadeOutDuration = 0.5
    }

    func loadGhostEffect()
    {
        // change the fragment color
        let shaderURL = Bundle.main.url(forResource: "character",
                                        withExtension: "shader")
        var fragmentModifier: String?
        do {
            try fragmentModifier = String(contentsOf: shaderURL!,
                                          encoding: String.Encoding.utf8)
        }
        catch _ {

        }

        let modifiers = [SCNShaderModifierEntryPoint.fragment : fragmentModifier]
        self.set(shaderModifiers: modifiers as! [SCNShaderModifierEntryPoint : String],
                 on: _characterNode!)
    }

    // recursive call
    func applyGhostEffect(_ show: Bool,
                          onNode node:SCNNode) {
        // Uniforms in your GLSL shaders can be set using KVC
        // The following line will set the 'ghostFactor' uniform found in the 'character.shader' file
        if show {
            node.geometry?.setValue(NSNumber(value: Float(1.0)),
                                    forKey: "ghostFactor")
        }
        else {
            node.geometry?.setValue(NSNumber(value: Float(0.0)),
                                    forKey: "ghostFactor")
        }
        for child in node.childNodes {
            self.applyGhostEffect(show,
                                   onNode:child)
        }
    }

    // recursive
    func set(shaderModifiers modifiers: [SCNShaderModifierEntryPoint : String],
             on node: SCNNode) {

        node.geometry?.shaderModifiers = modifiers

        for childNode in node.childNodes {
            self.set(shaderModifiers: modifiers,
                     on: childNode)
        }
    }

    func setShowsBones(_ show: Bool)
    {
        let scale: CGFloat = 1
        self.visualizeBones(show,
                            ofNode: _skeletonNode!,
                            inheritedScale: scale)
        self.applyGhostEffect(show,
                              onNode: _characterNode!)
    }

    func visualizeBones(_ show: Bool,
                        ofNode node: SCNNode,
                        inheritedScale scale: CGFloat) {

        // We propagate an inherited scale so that the boxes
        // representing the bones will be of the same size
        let newScale = scale * node.scale.x;

        if (show) {
            if (node.geometry == nil) {
                node.geometry = SCNBox(width: 6.0 / scale,
                                       height: 6.0 / scale,
                                       length: 6.0 / scale,
                                       chamferRadius: 0.5)
            }
        }
        else {
            if (node.geometry?.isKind(of: SCNBox.self))! {
                node.geometry = nil
            }
        }

        // recursive
        for child in node.childNodes {
            self.visualizeBones(show,
                                ofNode: child,
                                inheritedScale: newScale)
        }
    }

}
